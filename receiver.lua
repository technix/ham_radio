-- 		minetest.chat_send_player(user:get_player_name(), "Itemstack"..meta:get_string("frequency").."^"..itemstack:get_name())


minetest.register_tool("ham_radio:receiver", {
	description = "Ham Radio Receiver",
	wield_image = "ham_radio_receiver_wield.png",
	inventory_image = "ham_radio_receiver_wield.png",
	groups = { disable_repair = 1 },
	on_use = function(itemstack, user, pointed_thing)		
		local meta = itemstack:get_meta()
		local frequency = meta:get_string("frequency")
		minetest.show_formspec(user:get_player_name(), "ham_radio:configure_receiver", 
			"size[4,3]"..
			"field[0.25,0.25;3,1;frequency;Frequency;"..tostring(frequency).."]"..
			"button_exit[0.25,1.5;3,1;;Done]"
		)
		return itemstack
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "ham_radio:configure_receiver" or not minetest.is_player(player) then
        return false
    end
    if fields.frequency == "" or fields.frequency == nil then
		return false
    end
	local item = player:get_wielded_item()
	local meta = item:get_meta()
    meta:set_string("frequency", fields.frequency)
	player:set_wielded_item(item) -- replace wielded item with new metadata
	return true
end)
	
	
minetest.register_craft({
  output = "ham_radio:receiver",
  recipe = {
    {"default:glass"},
    {"default:steel_ingot"},
    {"default:glass"},
  }
})

function ham_radio:locate_transmitter(player, transmitter_pos)
    local player_pos = player:get_pos()
    local player_look_vector = player:get_look_dir()
    local player_direction = vector.add(player_pos, player_look_vector)

    local distance = vector.distance(player_pos, transmitter_pos)

    -- local distance_to_target = 13 - math.floor(math.log(distance*30))
    local distance_to_target = 24 - math.floor(2 * math.log(distance*10))

    local distance2 = vector.distance(player_direction, transmitter_pos)
    local signal_power = 1 - ((1 + distance2 - distance) / 2)

	return math.floor(distance_to_target * signal_power);
	
    --return {
    --   distance = distance_to_target,
    --   signal = signal_power
    -- }
end