ham_radio.settings = {
  -- color of broadcast messages
  broadcast_color = '#607d8b',
  -- interval between broadcasts (seconds)
  broadcast_interval = 10,
  -- receiver hud position
  hud_pos = { x = 0.5, y = 0.8 },
  -- radio frequency range
  frequency = {
    min = 0,
    max = 9999999
  },
  -- range where only one transmitter is permitted
  locked_frequency = {
    min = 100000,
    max = 9999999
  },
  -- sub-range of locked frequency range
  beacon_frequency = {
    min = 1000000,
    max = 9999999
  },
  -- digiline config
  digiline_channel = "ham_radio",
  digiline_broadcast_channel = "ham_radio_broadcast",
}
