function ham_radio.validate_frequency(frequency, is_receiver)
  if frequency == "" then
    return { result = true, message = '' } -- empty frequency is allowed to disable transmitter/receiver
  end
  local transmission_is_allowed = true
  local num_freq = tonumber(frequency)
  local freq = tostring(num_freq)
  if is_receiver == nil and next(ham_radio.find_transmitters(frequency)) then
    if num_freq >= ham_radio.settings.locked_frequency.min
    and num_freq <= ham_radio.settings.locked_frequency.max then
      -- transmitter is in locked frequency range
      transmission_is_allowed = false
    end
  end
  local result = true
  local message = ''
  if freq ~= frequency or num_freq ~= math.floor(num_freq) then
    result = false
    message = 'Error: invalid frequency value.'
  elseif num_freq == nil then
    result = false
    message = 'Error: frequency should be numeric.'
  elseif num_freq < ham_radio.settings.frequency.min or num_freq > ham_radio.settings.frequency.max then
    result = false
    message = 'Error: frequency is out of range.'
  elseif transmission_is_allowed == false then
    result = false
    message = 'Error: frequency is occupied by other transmitter.'
  end
  return { result = result, message = message }
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
