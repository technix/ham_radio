ham_radio.receiver_update_infotext = function(meta)
  local rds_message = meta:get_string("rds_message")
  local infotext = 'Radio receiver'
  if rds_message ~= "" then
    infotext = rds_message
  end
  meta:set_string("infotext", infotext)
end

minetest.register_node("ham_radio:receiver", {
  description = "Ham Radio Receiver",
  tiles = {
	  "ham_radio_receiver_top.png",
	  "ham_radio_receiver_top.png",
	  "ham_radio_receiver_side.png",
	  "ham_radio_receiver_side.png",
	  "ham_radio_receiver_side.png",
	  "ham_radio_receiver_front.png"
  },
  groups = {cracky=2,oddly_breakable_by_hand=2},
  sounds = default.node_sound_metal_defaults(),
  paramtype2 = "facedir",
  drawtype = "nodebox",
  paramtype = "light",
  node_box = {
    type = "fixed",
    fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
  },
  light_source = 3,
  after_place_node = function(pos, placer)
    local meta = minetest.get_meta(pos);
    local name = placer:get_player_name()
    meta:set_string("formspec",
      table.concat({
        "size[7,4]",
        "image[0,0;1,1;ham_radio_receiver_front.png]",
        "field[0.25,2;7,1;frequency;Frequency;${frequency}]",
        "tooltip[frequency;Integer number ",
          ham_radio.settings.frequency.min,"-",
          ham_radio.settings.frequency.max, "]",
        "button_exit[2,3.5;3,1;;Done]"
      },'')
    )
    meta:set_string("infotext", 'Radio Receiver')
  end,
  on_receive_fields = function(pos, formname, fields, sender)
    if not minetest.is_player(sender) then
      return
    end

    if (
      fields.quit ~= "true"
      or minetest.is_protected(pos, sender:get_player_name()) 
    ) then
      return
    end
    
    if fields.frequency ~= nil then
      local is_frequency_valid = ham_radio.validate_frequency(fields.frequency, true)
      if is_frequency_valid.result == false then
        ham_radio.errormsg(sender, is_frequency_valid.message)
      else
        local meta = minetest.get_meta(pos)
        meta:set_string("frequency", fields.frequency)
        meta:set_string("rds_message", "")
        ham_radio.reset_receiver(pos)
        ham_radio.receiver_update_infotext(meta)
        ham_radio.play_tuning_sound(sender)
      end
    end
  end,
  can_dig = function(pos,player)
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    local name = player:get_player_name()
    return inv:is_empty("main") and not minetest.is_protected(pos, name)
  end,
  -- digiline
  digiline = {
    receptor = {action = function() end},
    effector = {
      action = ham_radio.digiline_effector_receiver
    },
  },
});

ham_radio.reset_receiver = function (pos)
  local poshash = minetest.pos_to_string(pos, 0)
  ham_radio.receiver_rds[poshash] = nil
end

minetest.register_abm(
  {
    label = "Listen Ham Radion Broadcast",
    nodenames = {"ham_radio:receiver"},
    interval = 5,
    chance = 1,
    catch_up = false,
    action = function(pos, node)
      local meta = minetest.get_meta(pos)
      local frequency = meta:get_string("frequency")

      if frequency == "" then
        return
      end

      local poshash = minetest.pos_to_string(pos, 0)
      if ham_radio.receiver_rds[poshash] == nil or not next(ham_radio.receiver_rds[poshash]) then
        -- when all RDS messages are shown, reload them again
        ham_radio.receiver_rds[poshash] = ham_radio.get_rds_messages(frequency, true)
      end
      ham_radio.get_next_rds_message(poshash, meta)
    end
  }
);

ham_radio.get_next_rds_message = function (poshash, meta)
  local message = table.remove(ham_radio.receiver_rds[poshash])
  if message ~= nil then
    meta:set_string('rds_message', message)
    ham_radio.receiver_update_infotext(meta)
  end
end
