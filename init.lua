local modpath = minetest.get_modpath("ham_radio")
local mod_storage = minetest.get_mod_storage()

ham_radio = rawget(_G, "ham_radio") or {}

ham_radio = {
  playerhuds = {},
  is_receiver_wielded = {},
  settings = {
    hud_pos = { x = 0.5, y = 0.8 },
  }
}

function ham_radio.save_transmitter(pos, transmitter_properties)
  mod_storage:set_string(
    minetest.pos_to_string(pos, 0),
    minetest.write_json(transmitter_properties)
  )
end

function ham_radio.read_transmitter(pos)
  return mod_storage:get_string(minetest.pos_to_string(pos, 0))
end

function ham_radio.find_transmitters(frequency)
  local transmitter_list = {}
  local all_transmitters = mod_storage:to_table().fields
  for key, transmitter_data in pairs(all_transmitters) do
    local transmitter = minetest.parse_json(transmitter_data)
    if transmitter.frequency == frequency then
      transmitter_list[key] = transmitter
    end
  end
  return transmitter_list
end

function ham_radio.delete_transmitter(pos)
  mod_storage:set_string(minetest.pos_to_string(pos, 0), '')
end

dofile(modpath.."/craft.lua")
dofile(modpath.."/transmitter.lua")
dofile(modpath.."/receiver.lua") 
dofile(modpath.."/hud.lua")

-- TODO: craft transmitter
-- TODO: configure transmitter
-- TODO: craft pelengator
-- TODO: set pelengator frequency
