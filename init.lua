local modpath = minetest.get_modpath("ham_radio")
local mod_storage = minetest.get_mod_storage()

ham_radio = rawget(_G, "ham_radio") or {}

ham_radio = {
  playerhuds = {},
  player_broadcasts = {},
  is_receiver_wielded = {},
  transmitters = {},
  settings = {
    broadcast_color = '#607d8b',
    broadcast_interval = 10, -- seconds
    hud_pos = { x = 0.5, y = 0.8 },
    frequency = {
      min = 0,
      max = 9999999
    },
    digiline_channel = "ham_radio",
  }
}

-- preload transmitter data
local all_transmitters = mod_storage:to_table().fields
for key, transmitter_data in pairs(all_transmitters) do
  ham_radio.transmitters[key] = minetest.parse_json(transmitter_data)
end

function ham_radio.save_transmitter(pos, meta)
  local transmitter_properties = {
    frequency = meta:get_string("frequency"),
    broadcast_message = meta:get_string("broadcast_message"),
    operated_by = meta:get_string("operated_by")
  }
  local key = minetest.pos_to_string(pos, 0)
  ham_radio.transmitters[key] = transmitter_properties -- cache
  mod_storage:set_string(key, minetest.write_json(transmitter_properties)) -- storage
end

function ham_radio.delete_transmitter(pos)
  local key = minetest.pos_to_string(pos, 0)
  ham_radio.transmitters[key] = nil -- cache
  mod_storage:set_string(key, '') -- storage
end

dofile(modpath.."/helpers.lua")
dofile(modpath.."/craft.lua")
dofile(modpath.."/digiline.lua")
dofile(modpath.."/transmitter.lua")
dofile(modpath.."/receiver.lua")
dofile(modpath.."/broadcast.lua")
dofile(modpath.."/hud.lua")

-- globals

minetest.register_on_newplayer(ham_radio.toggle_hud)
minetest.register_on_joinplayer(ham_radio.toggle_hud)

minetest.register_on_leaveplayer(function(player)
  local name = player:get_player_name()
  ham_radio.is_receiver_wielded[name] = false
  ham_radio.playerhuds[name] = nil
end)

local updatetimer = 0
local broadcasttimer = 0
minetest.register_globalstep(function(dtime)
  updatetimer = updatetimer + dtime
  broadcasttimer = broadcasttimer + dtime
  if updatetimer > 0.1 then
    local players = minetest.get_connected_players()
    for i=1, #players do
      ham_radio:update_hud_display(players[i])
    end
    updatetimer = 0
  end
  if broadcasttimer > ham_radio.settings.broadcast_interval then
    local players = minetest.get_connected_players()
    for i=1, #players do
      ham_radio:update_broadcast(players[i])
    end
    broadcasttimer = 0
  end
end)

-- TODO: craft transmitter
-- TODO: configure transmitter
-- TODO: craft pelengator
-- TODO: set pelengator frequency
