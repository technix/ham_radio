function ham_radio.get_broadcast_messages(frequency)
  local transmitters = ham_radio.find_transmitters(frequency)
  local broadcasts = {}
  for position, transmitter in pairs(transmitters) do
    if transmitter.broadcast_message ~= "" then
      -- construct message
      local message = table.concat({
        '[ Radio | ',
        transmitter.operated_by,
        ' ] ',
        transmitter.broadcast_message,
      }, "")
      table.insert(broadcasts, message)
    end
  end
  return broadcasts
end


function ham_radio:update_broadcast(player)
  local name = player:get_player_name()
  local item = player:get_wielded_item()

  if item:get_name() ~= "ham_radio:handheld_receiver" then
    return
  end

  local meta = item:get_meta()
  local frequency = meta:get_string("frequency")
  local broadcast_disabled = meta:get_string("broadcast_disabled")

  if frequency == "" then
    return
  end

  if broadcast_disabled == "true" then
    -- disabled receiving broadcast messages
    ham_radio.player_broadcasts[name] = nil
    return
  end

  if ham_radio.player_broadcasts[name] == nil then
    ham_radio.player_broadcasts[name] = ham_radio.get_broadcast_messages(frequency)
  end
  
  local message = table.remove(ham_radio.player_broadcasts[name])
  if message ~= nil then
    minetest.chat_send_player(player:get_player_name(), minetest.colorize(ham_radio.settings.broadcast_color, message))

    -- when all broadcast messages are shown, reload them again
    if not next(ham_radio.player_broadcasts[name]) then    
      ham_radio.player_broadcasts[name] = ham_radio.get_broadcast_messages(frequency)
    end
  end
end
