ham_radio.settings = {
  -- color of RDS messages
  rds_color = '#4863A0',
  -- interval between RDS messages (seconds)
  rds_interval = 10,
  -- receiver hud position
  hud_pos = { x = 0.5, y = 0.8 },
  -- hud message color
  hud_color = {
    active = "0xFCAD00",
    inactive = "0x999999"
  },
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
  digiline_rds_channel = "ham_radio_rds",
  digiline_receiver_channel = "ham_radio_receiver",
}
