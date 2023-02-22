local mod_storage = minetest.get_mod_storage()
minetest.register_tool("ham_radio:handheld_transmitter", {
    description = "Handheld Radio Transmitter",
    wield_image = "ham_radio_transmitter_handheld.png",
    inventory_image = "ham_radio_transmitter_handheld.png",
    groups = { disable_repair = 1 },
    on_use = function(itemstack, user, pointed_thing)
        local meta = itemstack:get_meta()
        local frequency = meta:get_string("frequency")
        minetest.show_formspec(user:get_player_name(), "ham_radio:configure_handheld_transmitter",
        table.concat({
            "size[7,8]",
            "image[1,0;1,1;ham_radio_transmitter_handheld.png]",
            "field[0.25,2;3,1;frequency;Frequency;",tostring(frequency),"]",
            "tooltip[frequency;Integer number ",
            ham_radio.settings.frequency.min,"-",
            ham_radio.settings.frequency.max, "]",
            "textarea[0.25,3.5;7,4;rds_message;RDS message;This is a handheld transmitter in the hands of " .. minetest.formspec_escape(user:get_player_name()) .. "]",
            "button_exit[2,7.2;3,1;;Done]"
        },'')
        )
        return itemstack
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "ham_radio:configure_handheld_transmitter" or not minetest.is_player(player) then
      return false
    end
    if fields.frequency == nil then
      -- form is not sent
      return
    end
    local is_frequency_valid = ham_radio.validate_frequency(fields.frequency, true)
    if is_frequency_valid.result == false then
      ham_radio.errormsg(player, is_frequency_valid.message)
      return false
    end
    local item = player:get_wielded_item()
    local meta = item:get_meta()
    meta:set_string("frequency", fields.frequency)
    meta:set_string("rds_message", fields.rds_message)
    -- play radio sound
    ham_radio.play_tuning_sound(player)
     -- replace wielded item with new metadata
    player:set_wielded_item(item)
     -- reset rds messages
    ham_radio.player_rds[player:get_player_name()] = nil
    return true
  end)

local function save_transmitter(pos, frequency, rds_message, player_name)
    local player = minetest.get_player_by_name(player_name)
    local transmitter_properties = {
    frequency = frequency,
    rds_message = rds_message,
    operated_by = player_name,
    handheld = true,
    is_beacon = false,
    ss_pos = pos,
    ss_look_vector = player:get_look_dir()
    }
    local key = minetest.pos_to_string(pos, 0)
    if not mod_storage:contains(key) then
        mod_storage:set_string(key, minetest.write_json(transmitter_properties)) -- storage
    end
end
  
local function delete_transmitters(player)
    local all_transmitters = mod_storage:to_table().fields
    for key, transmitter_data in pairs(all_transmitters) do
        local transmitter = minetest.parse_json(transmitter_data)
        if transmitter.handheld == true then
            if transmitter.operated_by == player:get_player_name() then
                mod_storage:set_string(key, "")
            end
        end
    end
end

local function delete_inactive_transmitters()
    local all_transmitters = mod_storage:to_table().fields
    for key, transmitter_data in pairs(all_transmitters) do
        local transmitter = minetest.parse_json(transmitter_data)
        if transmitter.handheld == true then
            if minetest.get_player_by_name(transmitter.operated_by):get_wielded_item():get_name() ~= "ham_radio:handheld_transmitter" then
                mod_storage:set_string(key, "")
            end
        end
    end
end


  minetest.register_globalstep(function (dtime)
    delete_inactive_transmitters()
    for _, player in pairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        local inv = player:get_inventory()
        if player:get_wielded_item():get_name() == "ham_radio:handheld_transmitter" then
            local meta = player:get_wielded_item():get_meta()
            local frequency = meta:get_string("frequency")
            local rds_message = meta:get_string("rds_message")
            local player_name = player:get_player_name()
            if frequency == "" then
                frequency = "1"
            end
            delete_transmitters(player)
            save_transmitter(pos, frequency, rds_message, player_name)
        end
    end
  end)