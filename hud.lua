
function ham_radio.toggle_hud(player)
  local name = player:get_player_name()
  local item = player:get_wielded_item()
  
  -- remove hud and broadcasts if user does not wield a receiver
  if item:get_name() ~= "ham_radio:handheld_receiver" then
    if ham_radio.is_receiver_wielded[name] then
      for hud_id, hud_handler in pairs(ham_radio.playerhuds[name]) do
        player:hud_remove(hud_handler)
      end
      ham_radio.playerhuds[name] = nil
      ham_radio.is_receiver_wielded[name] = false
      ham_radio.player_broadcasts[name] = nil
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
      scale     = { x = 2, y = 2 },
      alignment = { x = 1, y = 0 },
    }),
    frequency = player:hud_add({
      hud_elem_type = "text",
      text = "",
      position  = hud_pos,
      offset    = { x = -220, y = 5 },
      alignment = { x = 1, y = 0},
      number = 0x999999,
      scale= { x = 100, y = 20 },
    }),
    broadcast = player:hud_add({
      hud_elem_type = "text",
      text = "",
      position  = hud_pos,
      offset    = { x = 220, y = 5 },
      alignment = { x = -1, y = 0},
      number = 0x999999,
      scale= { x = 100, y = 20 },
    }),
	  signal_meter = player:hud_add({
      hud_elem_type = "image",
      position  = hud_pos,
      offset    = { x = -220, y = 35 },
      text      = "ham_radio_hud_indicator_empty.png",
      scale     = { x = 2, y = 1 },
      alignment = { x = 1, y = 0 },
    }),
	  signal_level = player:hud_add({
	    hud_elem_type = "image",
      position  = hud_pos,
      offset    = { x = -220, y = 35 },
      text      = "ham_radio_hud_indicator_full.png",
      scale     = { x = 0, y = 1 },
      alignment = { x = 1, y = 0 },
    })
  }
  return true
end


function ham_radio:update_hud_display(player)

  if not ham_radio.toggle_hud(player) then
    return
  end

  local signal_power = 0
  local name = player:get_player_name()
  local meta = player:get_wielded_item():get_meta()
  local frequency = meta:get_string("frequency")

  if frequency ~= nil and frequency ~= "" then
    local transmitters = self.find_transmitters(frequency)
    for position, transmitter in pairs(transmitters) do
      local transmitter_signal = self:locate_transmitter(player, minetest.string_to_pos(position))
      if transmitter_signal > signal_power then
        -- use max power from transmitters nearby
        signal_power = transmitter_signal
      end
    end
  end

  if frequency == "" then
    player:hud_change(self.playerhuds[name].frequency, "text", "FQ ---")
    player:hud_change(self.playerhuds[name].frequency, "number", "0x999999")
  else
    player:hud_change(self.playerhuds[name].frequency, "text", "FQ "..frequency)
    player:hud_change(self.playerhuds[name].frequency, "number", "0xFCAD00")
  end

  if meta:get_string("broadcast_disabled") == "" then
    player:hud_change(self.playerhuds[name].broadcast, "text", "RDS ON")
    player:hud_change(self.playerhuds[name].broadcast, "number", "0xFCAD00")
  else
    player:hud_change(self.playerhuds[name].broadcast, "text", "RDS off")
    player:hud_change(self.playerhuds[name].broadcast, "number", "0x999999")
  end
  
  player:hud_change(
    self.playerhuds[name].signal_level,
    "scale",
    { x = signal_power/50 or 0.1, y = 1 } -- x scale should be 0-2
  )
end
