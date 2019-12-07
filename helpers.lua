function ham_radio.validate_frequency(frequency)
  local num_freq = tonumber(frequency)
  local freq = tostring(num_freq)
  return freq == frequency
    and num_freq ~= nil
    and num_freq == math.floor(num_freq)
    and num_freq >= ham_radio.settings.frequency.min
    and num_freq <= ham_radio.settings.frequency.max
end
