function ham_radio.validate_frequency(frequency)
  if frequency == "" then
    return true -- empty frequency is allowed to disable transmitter/receiver
  end
  local transmission_is_allowed = true
  local num_freq = tonumber(frequency)
  local freq = tostring(num_freq)
  if next(ham_radio.find_transmitters(frequency)) then
    if num_freq >= ham_radio.settings.locked_frequency.min
    and num_freq <= ham_radio.settings.locked_frequency.max then
      -- transmitter is in locked frequency range
      transmission_is_allowed = false
    end
  end
  return freq == frequency
    and num_freq ~= nil
    and num_freq == math.floor(num_freq)
    and num_freq >= ham_radio.settings.frequency.min
    and num_freq <= ham_radio.settings.frequency.max
    and transmission_is_allowed
end

function ham_radio.find_transmitters(frequency)
  local transmitter_list = {}
  for key, transmitter in pairs(ham_radio.transmitters) do
    if transmitter.frequency == frequency then
      transmitter_list[key] = transmitter
    end
  end
  return transmitter_list
end

function ham_radio.find_free_frequency(range)
  local frequency = -1
  while frequency == -1 do
    frequency = tostring(math.floor(math.random(range.min, range.max)));
    local are_there_transmitters = ham_radio.find_transmitters(frequency)
    if next(are_there_transmitters) then
      frequency = -1
    end
  end
  return frequency
end
