ham_radio.receiver_update_infotext = function(meta)
  local infotext = 'Radio receiver\n'
  infotext = infotext .. 'Frequency: ' .. meta:get_string("frequency") .. '\n'
  infotext = infotext .. 'Signal: ' .. meta:get_int("signal") .. '\n'
  infotext = infotext .. 'Digiline channel: ' .. meta:get_string("digiline_channel_command") .. '\n'
  infotext = infotext .. 'Message: ' .. meta:get_string("rds_message")
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
    meta:set_string('digiline_channel_command', ham_radio.settings.digiline_receiver_channel)
    meta:set_string("formspec",
      table.concat({
        "size[7,5]",
        "image[0,0;1,1;ham_radio_receiver_front.png]",
        "field[0.25,2;7,1;frequency;Frequency;${frequency}]",
        "tooltip[frequency;Integer number ",
          ham_radio.settings.frequency.min,"-",
          ham_radio.settings.frequency.max, "]",
        "field[0.25,3.5;7,1;command_channel;Digiline command channel;${digiline_channel_command}]",
        "button_exit[2,4.5;3,1;;Done]"
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

    local meta = minetest.get_meta(pos)
    if fields.command_channel ~= nil and fields.command_channel ~= "" then
      meta:set_string("digiline_channel_command", fields.command_channel)
    end
    
    if fields.frequency ~= nil then
      local is_frequency_valid = ham_radio.validate_frequency(fields.frequency, true)
      if is_frequency_valid.result == false then
        ham_radio.errormsg(sender, is_frequency_valid.message)
      else
        local meta = minetest.get_meta(pos)
        meta:set_string("frequency", fields.frequency)
        meta:set_string("rds_message", "")
        meta:set_int("signal", -1)
        ham_radio.reset_receiver(pos)
        ham_radio.play_tuning_sound(sender)
      end
    end
    ham_radio.receiver_update_infotext(meta)
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

local function locate_transmitter(pos, transmitter_pos)

  local coeff = 0.9
  local distance_to_target = 0

  local distance = vector.distance(pos, transmitter_pos)
  if distance < 3 then
    distance_to_target = 100
    coeff = 0.99
  else
    distance_to_target = -0.0000000001*math.pow(distance,3)+0.00000145*math.pow(distance,2)-0.03*distance+100
    if distance_to_target < 3 then
      distance_to_target = 3
    end
  end

  -- 0-100
  return distance_to_target * coeff + distance_to_target * (1 - coeff);
end


minetest.register_abm(
  {
    label = "Listen Ham Radion Broadcast",
    nodenames = {"ham_radio:receiver"},
    interval = 1,
    chance = 1,
    catch_up = false,
    action = function(pos, node)
      local meta = minetest.get_meta(pos)
      local frequency = meta:get_string("frequency")

      if frequency == "" then
        return
      end

      local poshash = minetest.pos_to_string(pos, 0)

      local signal_power = 0
      local transmitters = ham_radio.find_transmitters(frequency)
      for position, transmitter in pairs(transmitters) do
        local transmitter_signal = locate_transmitter(pos, minetest.string_to_pos(position))
        if transmitter_signal > signal_power then
          -- use max power from transmitters nearby
          signal_power = transmitter_signal
        end
      end
      meta:set_int("signal", signal_power)
      

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
  if message == nil then
    message = "No message"
  end
  meta:set_string('rds_message', message)
  ham_radio.receiver_update_infotext(meta)
end
