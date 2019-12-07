
function ham_radio.toggle_hud(player)
  local name = player:get_player_name()
  local item = player:get_wielded_item()
  
  -- remove hud if user does not wield a receiver
  if item:get_name() ~= "ham_radio:receiver" then
    if ham_radio.is_receiver_wielded[name] then
	  player:hud_remove(ham_radio.playerhuds[name].background)
      player:hud_remove(ham_radio.playerhuds[name].frequency)
	  player:hud_remove(ham_radio.playerhuds[name].signal_meter)
	  player:hud_remove(ham_radio.playerhuds[name].signal_level)
      ham_radio.is_receiver_wielded[name] = false
    end
    return false
  end

  -- if hud is already enabled, pass
  if ham_radio.is_receiver_wielded[name] then
	return true
  end

  -- create hud
  ham_radio.is_receiver_wielded[name] = true

  local hud_pos = ham_radio.settings.hud_pos
  
  ham_radio.playerhuds[name] = {
    background = player:hud_add({
      hud_elem_type = "image",
      position  = hud_pos,
      offset    = { x = -250, y = 20 },
      text      = "ham_radio_hud_bg.png",
      scale     = { x = 2, y = 3 },
      alignment = { x = 1, y = 0 },
    }),
    frequency = player:hud_add({
      hud_elem_type = "text",
      text = "",
      position  = hud_pos,
      offset    = { x = 0, y = 0 },
      alignment = 0,
      number = 0xFFFFFF,
      scale= { x = 100, y = 20 },
    }),
	signal_meter = player:hud_add({
      hud_elem_type = "image",
      position  = hud_pos,
      offset    = { x = -220, y = 30 },
      text      = "ham_radio_hud_indicator_empty.png",
      scale     = { x = 2, y = 2 },
      alignment = { x = 1, y = 0 },
    }),
	signal_level = player:hud_add({
	  hud_elem_type = "image",
      position  = hud_pos,
      offset    = { x = -220, y = 30 },
      text      = "ham_radio_hud_indicator_full.png",
      scale     = { x = 0, y = 2 },
      alignment = { x = 1, y = 0 },
    })
  }
  return true
end


function ham_radio:update_hud_display(player)

  if not ham_radio.toggle_hud(player) then
    return
  end

  local transmitter_signal = 0
  local name = player:get_player_name()
  local meta = player:get_wielded_item():get_meta()
  local frequency = meta:get_string("frequency")
  
  if frequency ~= nil and frequency ~= "" then
    local transmitter = self.read_transmitter(frequency)
    -- minetest.chat_send_player(player:get_player_name(), "Found transmitter:"..minetest.serialize(transmitter))
    if transmitter.pos then
      transmitter_signal = self:locate_transmitter(player, transmitter.pos)
    end
  end
  -- local target_pos = {x=-407, y = 59, z = 70}

    --local indicator = string.rep('|', transmitter.distance)..string.rep('|', transmitter.signal)..string.rep(':', 25-(transmitter.distance + transmitter.signal))
  local indicator = string.rep('|', transmitter_signal)..string.rep(':', 20 - transmitter_signal)

  --local text = "[ Frequency: "..tostring(meta:get_string("frequency")).." ]"..indicator
  local text = "[ Frequency: "..tostring(meta:get_string("frequency")).." ]"
  player:hud_change(self.playerhuds[name].frequency, "text", text)
  player:hud_change(self.playerhuds[name].signal_level, "scale", { x = (transmitter_signal * 20) / 200 or 0.1, y = 2 })
end

minetest.register_on_newplayer(ham_radio.toggle_hud)
minetest.register_on_joinplayer(ham_radio.toggle_hud)

minetest.register_on_leaveplayer(function(player)
  ham_radio.is_receiver_wielded[name] = false
  ham_radio.playerhuds[player:get_player_name()] = nil
end)

local updatetimer = 0
minetest.register_globalstep(function(dtime)
  updatetimer = updatetimer + dtime
  if updatetimer > 0.1 then
    local players = minetest.get_connected_players()
    for i=1, #players do
      ham_radio:update_hud_display(players[i])
    end
    updatetimer = updatetimer - dtime
  end
end)
