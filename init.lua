local modpath = minetest.get_modpath("ham_radio")
local mod_storage = minetest.get_mod_storage()

ham_radio = rawget(_G, "ham_radio") or {}

ham_radio = {
  playerhuds = {},
  playerlocators = {},
  settings = {
    hud_pos = { x = 0.45, y = 0.7 },
    hud_offset = { x = 15, y = 15 },
    hud_alignment = { x = 1, y = 0 }
  }
}

function ham_radio.save_transmitter(frequency, transmitter_data)
  mod_storage:set_string(tostring(frequency), minetest.write_json(transmitter_data))
end

function ham_radio.read_transmitter(frequency)
  local transmitter_data = mod_storage:get_string(tostring(frequency))
  if transmitter_data ~= nil and transmitter_data ~= "" then
    return minetest.parse_json(transmitter_data)
  end
  return {}
end

function ham_radio.delete_transmitter(frequency)
  mod_storage:set_string(tostring(frequency), nil)
end

dofile(modpath.."/transmitter.lua")
dofile(modpath.."/receiver.lua") 
dofile(modpath.."/hud.lua")

-- TODO: craft transmitter
-- TODO: configure transmitter
-- TODO: craft pelengator
-- TODO: set pelengator frequency
