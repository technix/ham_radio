local modpath = minetest.get_modpath("ham_radio")
local mod_storage = minetest.get_mod_storage()

ham_radio = rawget(_G, "ham_radio") or {}

ham_radio = {
  playerhuds = {},
  is_receiver_wielded = {},
  transmitters = {},
  settings = {
    hud_pos = { x = 0.5, y = 0.8 },
    frequency = {
      min = 0,
      max = 9999999
    }
  }
}

-- preload transmitter data
local all_transmitters = mod_storage:to_table().fields
for key, transmitter_data in pairs(all_transmitters) do
  ham_radio.transmitters[key] = minetest.parse_json(transmitter_data)
end

function ham_radio.save_transmitter(pos, transmitter_properties)
  local key = minetest.pos_to_string(pos, 0)
  ham_radio.transmitters[key] = transmitter_properties -- cache
  mod_storage:set_string(key, minetest.write_json(transmitter_properties)) -- storage
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

function ham_radio.delete_transmitter(pos)
  local key = minetest.pos_to_string(pos, 0)
  ham_radio.transmitters[key] = nil -- cache
  mod_storage:set_string(key, '') -- storage
end

dofile(modpath.."/helpers.lua")
dofile(modpath.."/craft.lua")
dofile(modpath.."/transmitter.lua")
dofile(modpath.."/receiver.lua") 
dofile(modpath.."/hud.lua")

-- TODO: craft transmitter
-- TODO: configure transmitter
-- TODO: craft pelengator
-- TODO: set pelengator frequency
