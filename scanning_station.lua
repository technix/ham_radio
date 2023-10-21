local mod_storage = minetest.get_mod_storage()
local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end
  
ham_radio.scanner_update_infotext = function(meta)
    local infotext = 'Radio Scanner\n'
    infotext = infotext .. 'Active frequencies: ' .. meta:get_int("active_frequencies") .. '\n'
    infotext = infotext .. 'Digiline channel: ' .. meta:get_string("digiline_channel_command") .. '\n'
    --infotext = infotext .. '\nActive frequencies: ' .. meta:get_string("transmitter_db")
    meta:set_string("infotext", infotext)
  end
  
  local function updateform()
    return table.concat({
      "size[30,16]",
      "image[0,0;1,1;ham_radio_scanner_front.png]",
      "field[0.25,2;7,1;command_channel;Digiline command channel;${digiline_channel_command}]",
      "textarea[0.25,3;30,13;stations;Stations;${stations_readable}]",
      "button_exit[13.5,15;3,1;;Done]"
    },'')
  end

  minetest.register_node("ham_radio:scanner", {
    description = "Ham Radio Scanner",
    tiles = {
      "ham_radio_scanner_top.png",
      "ham_radio_scanner_top.png",
      "ham_radio_scanner_side.png",
      "ham_radio_scanner_side.png",
      "ham_radio_scanner_side.png",
      "ham_radio_scanner_front.png"
    },
    groups = {cracky=2,oddly_breakable_by_hand=2},
    sounds = default.node_sound_metal_defaults(),
    paramtype2 = "facedir",
    drawtype = "nodebox",
    paramtype = "light",
    light_source = 3,
    after_place_node = function(pos, placer)
      local meta = minetest.get_meta(pos)
      meta:set_string("infotext", 'Radio Scanner')
      meta:set_string("digiline_channel_command", ham_radio.settings.digiline_scanner_channel)
      meta:set_string("formspec", updateform())
    end,
    on_receive_fields = function(pos, formname, fields, sender)
      if not minetest.is_player(sender) then
        return
      end
  
      if (
        fields.quit ~= "true"
        or minetest.is_protected(pos, sender:get_player_name()) 
      ) then
        return
      end
      local meta = minetest.get_meta(pos)
  
      if fields.command_channel ~= nil and fields.command_channel ~= "" then
        meta:set_string("digiline_channel_command", fields.command_channel)
      end
      ham_radio.scanner_update_infotext(meta)
    end,
    can_dig = function(pos,player)
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory()
      local name = player:get_player_name()
      return inv:is_empty("main") and not minetest.is_protected(pos, name)
    end,
    -- digiline
    digiline = {
      receptor = {action = function() end},
      effector = {
        action = ham_radio.digiline_effector_scanner
      },
    },
  });
  
  local function locate_transmitter(pos, transmitter_pos)
  
    local coeff = 0.9
    local distance_to_target = 0
  
    local distance = vector.distance(pos, transmitter_pos)
    if distance < 3 then
      distance_to_target = 100
      coeff = 0.99
    else
      distance_to_target = -0.0000000001*math.pow(distance,3)+0.00000145*math.pow(distance,2)-0.03*distance+100
      if distance_to_target < 3 then
        distance_to_target = 3
      end
    end
  
    -- 0-100
    return distance_to_target * coeff + distance_to_target * (1 - coeff);
  end
  
  
  minetest.register_abm(
    {
      label = "Scan Ham Radio Broadcasts",
      nodenames = {"ham_radio:scanner"},
      interval = 1,
      chance = 1,
      catch_up = false,
      action = function(pos, node)
        local meta = minetest.get_meta(pos)  
  
        local transmitter_db = {}
        local all_transmitters = mod_storage:to_table().fields
        local readable_stations = ""
        local i = 0
        for key, transmitter_data in pairs(all_transmitters) do
            local transmitter = minetest.parse_json(transmitter_data)
            local transmitter_signal = locate_transmitter(pos, minetest.string_to_pos(key))
            local this_transmitter = {
            frequency = transmitter.frequency,
            rds_message = transmitter.rds_message,
            operated_by = transmitter.operated_by,
            handheld = transmitter.handheld,
            is_beacon = transmitter.is_beacon,
            signal = transmitter_signal}
            readable_stations = readable_stations .. "Transmitter " .. tostring(i) .. ":\n"
            readable_stations = readable_stations .. "  - Frequency:" .. tostring(transmitter.frequency) .. "\n"
            readable_stations = readable_stations .. "  - RDS message:" .. tostring(transmitter.rds_message) .. "\n"
            readable_stations = readable_stations .. "  - Operated by:" .. tostring(transmitter.operated_by) .. "\n"
            readable_stations = readable_stations .. "  - Handheld:" .. tostring(transmitter.handheld) .. "\n"
            readable_stations = readable_stations .. "  - Is beacon:" .. tostring(transmitter.is_beacon) .. "\n"
            table.insert(transmitter_db, this_transmitter)
            i = i + 1
        end
        local transmitter_db_serialized = minetest.write_json(transmitter_db)
        meta:set_string("transmitter_db", transmitter_db_serialized)
        local active_frequencies = tablelength(transmitter_db)
        meta:set_int("active_frequencies", active_frequencies)
        meta:set_string("stations_readable", readable_stations)
        meta:set_string("formspec", updateform())
        ham_radio.scanner_update_infotext(meta)
        
  
      end
    }
  );