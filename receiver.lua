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
      table.concat({
        "size[3,4]",
        "image[1,0;1,1;ham_radio_receiver_wield.png]",
        "field[0.25,2;3,1;frequency;Frequency;",tostring(frequency),"]",
        "tooltip[frequency;Integer number ",
          ham_radio.settings.frequency.min,"-",
          ham_radio.settings.frequency.max, "]",
        "button_exit[0,3.5;3,1;;Done]"
      },'')
    )
    return itemstack
  end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "ham_radio:configure_receiver" or not minetest.is_player(player) then
    return false
  end
  if not ham_radio.validate_frequency(fields.frequency) then
    return false
  end
  local item = player:get_wielded_item()
  local meta = item:get_meta()
  meta:set_string("frequency", fields.frequency)
  player:set_wielded_item(item) -- replace wielded item with new metadata
  return true
end)


function ham_radio:locate_transmitter(player, transmitter_pos)
  local player_pos = player:get_pos()
  local player_look_vector = player:get_look_dir()
  local player_direction = vector.add(player_pos, player_look_vector)

  local coeff = 0.9
  local distance_to_target = 0

  local distance = vector.distance(player_pos, transmitter_pos)
  if distance < 3 then
    distance_to_target = 100
    coeff = 0.99
  else
    distance_to_target = -0.0000000001*math.pow(distance,3)+0.00000145*math.pow(distance,2)-0.03*distance+100
    if distance_to_target < 3 then
      distance_to_target = 3
    end
  end

  local distance2 = vector.distance(player_direction, transmitter_pos)
  local signal_power = distance - distance2;

  -- 0-100
  return distance_to_target * coeff + distance_to_target * (1 - coeff) * signal_power;
end
