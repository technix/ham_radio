function ham_radio.get_rds_messages(frequency, is_receiver_station)
  local transmitters = ham_radio.find_transmitters(frequency)
  local rds_messages = {}
  for position, transmitter in pairs(transmitters) do
    if transmitter.rds_message ~= "" and transmitter.rds_message ~= nil then
      for rds_message_line in transmitter.rds_message:gmatch("[^\n]+") do
        -- construct message
        local message = table.concat({
          '[ Radio | ',
          transmitter.operated_by,
          ' ] ',
          rds_message_line,
        }, "")
        if is_receiver_station then
          message = table.concat({
            '[ ',
            transmitter.operated_by,
            ' ] ',
            rds_message_line
          }, "")
        end
        table.insert(rds_messages, 1, message)
      end
    end
  end
  return rds_messages
end


function ham_radio:update_rds(player)
  local name = player:get_player_name()
  local item = player:get_wielded_item()

  if item:get_name() ~= "ham_radio:handheld_receiver" then
    return
  end

  local meta = item:get_meta()
  local frequency = meta:get_string("frequency")
  local rds_disabled = meta:get_string("rds_disabled")

  if frequency == "" then
    return
  end

  if rds_disabled == "true" then
    -- disabled receiving RDS messages
    ham_radio.player_rds[name] = nil
    return
  end

  if ham_radio.player_rds[name] == nil then
    ham_radio.player_rds[name] = ham_radio.get_rds_messages(frequency)
  end
  
  local message = table.remove(ham_radio.player_rds[name])
  if message ~= nil then
    minetest.chat_send_player(player:get_player_name(), minetest.colorize(ham_radio.settings.rds_color, message))

    -- when all RDS messages are shown, reload them again
    if not next(ham_radio.player_rds[name]) then
      ham_radio.player_rds[name] = ham_radio.get_rds_messages(frequency)
    end
  end
end
