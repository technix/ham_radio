
ham_radio.transmitter_update_infotext = function(meta)
  local operated_by = meta:get_string("operated_by")
  local frequency = meta:get_string("frequency")
  local rds_message = meta:get_string("rds_message")
  if frequency == "" then
    frequency = "--"
    rds_message = ""
  end
  local infotext = {
    'Radio Transmitter\n',
    'Operated by: ', operated_by, '\n',
    'Frequency: ', frequency
  }
  if rds_message ~= "" then
    table.insert(infotext, '\nRDS message: "')
    table.insert(infotext, rds_message)
    table.insert(infotext, '"')
  end
  meta:set_string("infotext", table.concat(infotext, ''))
end

minetest.register_node("ham_radio:transmitter", {
  description = "Radio Transmitter",
  tiles = {
    "ham_radio_transmitter_top.png",
    "ham_radio_transmitter_top.png",
    "ham_radio_transmitter_side.png",
    "ham_radio_transmitter_side.png",
    "ham_radio_transmitter_side.png",
    "ham_radio_transmitter_front.png"
  },
  groups = {cracky=2,oddly_breakable_by_hand=2},
  sounds = default.node_sound_metal_defaults(),
  paramtype2 = "facedir",
  light_source = 3,
  after_place_node = function(pos, placer)
    local meta = minetest.get_meta(pos);
    local name = placer:get_player_name()
    meta:set_string('operated_by', name)
    meta:set_string('rds_message', "")
    meta:set_string("formspec",
      table.concat({
        "size[7,8]",
        "image[0,0;1,1;ham_radio_transmitter_front.png]",
        "label[1,0;Transmitter operated by: ",minetest.formspec_escape(name),"]",
        "field[0.25,2;7,1;frequency;Frequency;${frequency}]",
        "tooltip[frequency;Integer number ",
          ham_radio.settings.frequency.min,"-",
          ham_radio.settings.frequency.max, "]",
        "textarea[0.25,3.5;7,4;rds_message;RDS message;${rds_message}]",
        "button_exit[2,7.5;3,1;;Done]"
      },'')
    )
    ham_radio.transmitter_update_infotext(meta)
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

    local meta = minetest.get_meta(pos)
    local transmitter_is_updated = false

    if fields.frequency ~= nil and fields.frequency ~= meta:get_string("frequency") then
      local is_frequency_valid = ham_radio.validate_frequency(fields.frequency)
      if is_frequency_valid.result == false then
        ham_radio.errormsg(sender, is_frequency_valid.message)
      else
        meta:set_string("frequency", fields.frequency)
        transmitter_is_updated = true
      end
    end

    if fields.rds_message ~= nil and fields.rds_message ~= meta:get_string("rds_message") then
      meta:set_string("rds_message", fields.rds_message)
      transmitter_is_updated = true
    end

    if transmitter_is_updated then
      ham_radio.transmitter_update_infotext(meta)
      ham_radio.save_transmitter(pos, meta)
      ham_radio.play_tuning_sound(sender)
    end
  end,
  can_dig = function(pos,player)
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    local name = player:get_player_name()
    return inv:is_empty("main") and not minetest.is_protected(pos, name)
  end,
  after_dig_node = function(pos, oldnode, oldmetadata, player)
    ham_radio.delete_transmitter(pos)
  end,
  -- digiline
  digiline = {
    receptor = {action = function() end},
    effector = {
      action = ham_radio.digiline_effector_transmitter
    },
  },
});
