function ham_radio.validate_frequency(frequency)
  local num_freq = tonumber(frequency)
  local freq = tostring(num_freq)
  return freq == frequency
    and num_freq ~= nil
    and num_freq == math.floor(num_freq)
    and num_freq >= ham_radio.settings.frequency.min
    and num_freq <= ham_radio.settings.frequency.max
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

function ham_radio.find_free_frequency()
  local frequency = -1
  while frequency == -1 do
    frequency = tostring(math.floor(math.random(ham_radio.settings.frequency.min, ham_radio.settings.frequency.max)));
    local are_there_transmitters = ham_radio.find_transmitters(frequency)
    if next(are_there_transmitters) then
      frequency = -1
    end
  end
  return frequency
end
