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

function ham_radio.save_transmitter(frequency, pos, transmitter_properties)
  local transmitters = mod_storage:get_string(tostring(frequency))
  local transmitter_list = {}
  if transmitters ~= "" then
    transmitter_list = minetest.parse_json(transmitters)
  end
  transmitter_list[minetest.pos_to_string(pos, 0)] = transmitter_properties
  mod_storage:set_string(tostring(frequency), minetest.write_json(transmitter_list))
end

function ham_radio.read_transmitters(frequency)
  local transmitters = mod_storage:get_string(tostring(frequency))
  if transmitters ~= "" then
    return minetest.parse_json(transmitters)
  end
  return {}
end

function ham_radio.delete_transmitter(frequency, pos)
  local transmitters = mod_storage:get_string(tostring(frequency))
  if transmitters ~= "" then
    local transmitter_list = minetest.parse_json(transmitters)
    transmitter_list[minetest.pos_to_string(pos, 0)] = nil
    if next(transmitter_list) == nil then
      mod_storage:set_string(tostring(frequency),"")
    else
      mod_storage:set_string(tostring(frequency), minetest.write_json(transmitter_list))
    end
  end
end

dofile(modpath.."/craft.lua")
dofile(modpath.."/transmitter.lua")
dofile(modpath.."/receiver.lua") 
dofile(modpath.."/hud.lua")

-- TODO: craft transmitter
-- TODO: configure transmitter
-- TODO: craft pelengator
-- TODO: set pelengator frequency
