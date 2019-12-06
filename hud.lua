
function ham_radio.init_hud(player)
    local name = player:get_player_name()
    ham_radio.playerhuds[name] = player:hud_add({
		hud_elem_type = "text",
		text = "",
		position = ham_radio.settings.hud_pos,
		offset = { x = ham_radio.settings.hud_offset.x, y = ham_radio.settings.hud_offset.y },
		alignment = ham_radio.settings.hud_alignment,
		number = 0xFFFFFF,
		scale= { x = 100, y = 20 },
    })
end


function ham_radio:update_hud_display(player)
    local transmitter_signal = 0

    local name = player:get_player_name()
    local item = player:get_wielded_item()

    if item:get_name() ~= "ham_radio:receiver" then
        if self.playerlocators[name] then
          player:hud_change(self.playerhuds[name], "text", "")
          self.playerlocators[name] = false
        end
        return
    end
    self.playerlocators[name] = true
	
	local meta = item:get_meta()
	local frequency = meta:get_string("frequency")

	minetest.chat_send_player(player:get_player_name(), "Configured freq:"..frequency)
	
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

    local text = "[ Frequency: "..tostring(meta:get_string("frequency")).." ]"..indicator

    player:hud_change(self.playerhuds[name], "text", text)
end

minetest.register_on_newplayer(ham_radio.init_hud)
minetest.register_on_joinplayer(ham_radio.init_hud)

minetest.register_on_leaveplayer(function(player)
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
