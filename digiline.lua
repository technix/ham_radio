ham_radio.digiline_effector_transmitter = function(pos, _, channel, msg)
   -- static channels for transmitter
  local command_channel = ham_radio.settings.digiline_channel
  local rds_channel = ham_radio.settings.digiline_rds_channel

  if channel ~= command_channel and channel ~= rds_channel then
    return
  end

  local meta = minetest.get_meta(pos)

  -- RDS channel - text message
  if channel == rds_channel then
    if type(msg) == "string" then
      meta:set_string("rds_message", msg)
      ham_radio.transmitter_update_infotext(meta)
      ham_radio.save_transmitter(pos, meta)
    end
    return
  end

  -- command channel

  if type(msg) ~= "table" then
    return
  end

  if msg.command == "get" then
    digilines.receptor_send(pos, digilines.rules.default, command_channel, {
      frequency = meta:get_string("frequency"),
      rds_message = meta:get_string("rds_message"),
    })

  elseif msg.command == "frequency" or msg.command == "set_frequency" then
    local new_frequency = msg.value
    local validate = ham_radio.validate_frequency(new_frequency)
    if validate.result then
      meta:set_string("frequency", new_frequency)
      ham_radio.transmitter_update_infotext(meta)
      ham_radio.save_transmitter(pos, meta)  
    end
    digilines.receptor_send(pos, digilines.rules.default, command_channel, {
      update = 'frequency',
      success = validate.result,
      message = validate.message
    })

  elseif msg.command == "rds" or msg.command == "message" or msg.command == "rds_message" or msg.command == "set_rds_message" then
    meta:set_string("rds_message", msg.value)
    ham_radio.transmitter_update_infotext(meta)
    ham_radio.save_transmitter(pos, meta)  
    digilines.receptor_send(pos, digilines.rules.default, command_channel, {
      update = 'rds_message',
      success = true
    })
  end
end


ham_radio.digiline_effector_receiver = function(pos, _, channel, msg)
  -- static channel for receiver
  local command_channel = ham_radio.settings.digiline_receiver_channel

  if channel ~= command_channel or type(msg) ~= "table" then
    return
  end

  local meta = minetest.get_meta(pos)

  if msg.command == "get" then
    digilines.receptor_send(pos, digilines.rules.default, command_channel, {
      frequency = meta:get_string("frequency"),
      rds_message = meta:get_string("rds_message"),
    })

  elseif msg.command == "frequency" or msg.command == "set_frequency" then
    local new_frequency = msg.value
    local validate = ham_radio.validate_frequency(new_frequency, true)
    if validate.result then
      meta:set_string("frequency", new_frequency)
      -- load new RDS messages
      local poshash = minetest.pos_to_string(pos, 0)
      ham_radio.receiver_rds[poshash] = ham_radio.get_rds_messages(new_frequency, true)
      ham_radio.get_next_rds_message(poshash, meta)
    end
    digilines.receptor_send(pos, digilines.rules.default, command_channel, {
      update = 'frequency',
      success = validate.result,
      message = validate.message
    })
  end

end