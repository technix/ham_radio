ham_radio.digiline_effector = function(pos, _, channel, msg)
  local digiline_channel = ham_radio.settings.digiline_channel -- static channel

  if type(msg) ~= "table" or channel ~= digiline_channel then
    return
  end

  local meta = minetest.get_meta(pos)

  if msg.command == "get" then
    digilines.receptor_send(pos, digilines.rules.default, digiline_channel, {
      frequency = meta:get_string("frequency"),
      broadcast_message = meta:get_string("broadcast_message"),
    })

  elseif msg.command == "frequency" then
    local new_frequency = msg.value
    if ham_radio.validate_frequency(new_frequency) then
      meta:set_string("frequency", new_frequency)
      ham_radio.transmitter_update_infotext(meta)
      ham_radio.save_transmitter(pos, meta)  
    end

  elseif msg.command == "broadcast" or msg.command == "message" or msg.command == "broadcast_message" then
    meta:set_string("broadcast_message", msg.value)
    ham_radio.transmitter_update_infotext(meta)
    ham_radio.save_transmitter(pos, meta)  

  end
end