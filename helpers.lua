function ham_radio.validate_frequency(frequency)
  if frequency == nil then
    return false
  end
  local num_freq = math.floor(tonumber(frequency))
  local freq = tostring(num_freq)
  return freq == frequency
    and num_freq >= ham_radio.settings.frequency.min
    and num_freq <= ham_radio.settings.frequency.max
end
