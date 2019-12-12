local modpath = minetest.get_modpath("ham_radio")
local mod_storage = minetest.get_mod_storage()

ham_radio = rawget(_G, "ham_radio") or {}

ham_radio = {
  playerhuds = {},
  player_rds = {},
  receiver_rds = {},
  is_receiver_wielded = {},
  transmitters = {},
}

-- preload transmitter data
local all_transmitters = mod_storage:to_table().fields
for key, transmitter_data in pairs(all_transmitters) do
  ham_radio.transmitters[key] = minetest.parse_json(transmitter_data)
end

function ham_radio.save_transmitter(pos, meta)
  local transmitter_properties = {
    frequency = meta:get_string("frequency"),
    rds_message = meta:get_string("rds_message"),
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

function ham_radio.play_tuning_sound(player)
  minetest.sound_play(
    {name = "ham_radio_tuning"..math.random(1,5)},
    {to_player = player:get_player_name()}
  )
end

function ham_radio.errormsg(player, message)
  minetest.chat_send_player(player:get_player_name(), minetest.colorize("#FCAD00", message))
end

dofile(modpath.."/config.lua")

dofile(modpath.."/helpers.lua")
dofile(modpath.."/craft.lua")
dofile(modpath.."/digiline.lua")
dofile(modpath.."/transmitter.lua")
dofile(modpath.."/receiver.lua")
dofile(modpath.."/beacon.lua")
dofile(modpath.."/rds.lua")
dofile(modpath.."/receiver_station.lua")
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
local rds_timer = 0
minetest.register_globalstep(function(dtime)
  updatetimer = updatetimer + dtime
  rds_timer = rds_timer + dtime
  if updatetimer > 0.1 then
    local players = minetest.get_connected_players()
    for i=1, #players do
      ham_radio:update_hud_display(players[i])
    end
    updatetimer = 0
    -- rds update timer
    if rds_timer > ham_radio.settings.rds_interval then
      for i=1, #players do
        ham_radio:update_rds(players[i])
      end
      rds_timer = 0
    end
  end
end)
