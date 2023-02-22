local mod_storage = minetest.get_mod_storage()
local beacon_update_infotext = function(meta)
  local operated_by = meta:get_string("operated_by")
  local frequency = meta:get_string("frequency")
  local rds_message = meta:get_string("rds_message")
  if frequency == "" then
    frequency = "--"
    rds_message = ""
  end
  local infotext = {
    'Radio Beacon\n',
    'Operated by: ', operated_by, '\n',
    'Frequency: ', frequency
  }
  if rds_message ~= "" then
    table.insert(infotext, '\nRDS message: "')
    table.insert(infotext, rds_message)
    table.insert(infotext, '"')
  end
  meta:set_string("infotext", table.concat(infotext, ''))
end

local function save_beacon(pos, meta)
  local transmitter_properties = {
    frequency = meta:get_string("frequency"),
    rds_message = meta:get_string("rds_message"),
    operated_by = meta:get_string("operated_by"),
    handheld = false,
    is_beacon = true
  }
  local key = minetest.pos_to_string(pos, 0)
  mod_storage:set_string(key, minetest.write_json(transmitter_properties)) -- storage
end

minetest.register_node("ham_radio:beacon", {
  description = "Radio Beacon",
  tiles = {
    "ham_radio_transmitter_top.png",
    "ham_radio_transmitter_top.png",
    "ham_radio_transmitter_side.png",
    "ham_radio_transmitter_side.png",
    "ham_radio_transmitter_side.png",
    "ham_radio_beacon_front.png"
  },
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
    local transmitter_is_updated = false
    local gpsbutton = false
    if(fields.engps == "Enable GPS") then
      gpsbutton = true
    end

      meta:set_string("GPS_enabled", "false")
      meta:set_string("rds_message" , "This is a beacon at: GPS is disabled")
      if gpsbutton == true then
        meta:set_string("GPS_enabled", "true")
        meta:set_string("rds_message", "This is a beacon at:" .. minetest.pos_to_string(pos))
      end
      transmitter_is_updated = true

    if transmitter_is_updated then
      beacon_update_infotext(meta)
      save_beacon(pos, meta)
      ham_radio.play_tuning_sound(sender)
    end
  end,
  groups = {cracky=2,oddly_breakable_by_hand=2},
  sounds = default.node_sound_metal_defaults(),
  paramtype2 = "facedir",
  drawtype = "nodebox",
  paramtype = "light",
  node_box = {
    type = "fixed",
    fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
  },
  light_source = 3,
  after_place_node = function(pos, placer)
    local meta = minetest.get_meta(pos);
    local name = "anonymous"
    if minetest.is_player(placer) then
      name = placer:get_player_name()
      if name == "" then
        name = "anonymous"
      end
      meta:set_string('operated_by', name)
      ham_radio.play_tuning_sound(placer)
    end
    local freq = ham_radio.find_free_frequency(ham_radio.settings.beacon_frequency)
    meta:set_string("frequency", freq)
    meta:set_string("rds_message" , "This is a beacon at: GPS is disabled")
    meta:set_string("GPS_enabled", "false")
    meta:set_string("formspec",
      table.concat({
        "size[7,6]",
        "image[0.25,-1;4,4;ham_radio_beacon_front.png]",
        "label[0.25,0;Beacon operated by: ",minetest.formspec_escape(name),"]",
        "label[0.25,2.75;Frequency: ", minetest.formspec_escape(freq), "]",
        "button_exit[2,4;3,1;engps;Disable GPS]",
        "button_exit[2,5;3,1;engps;Enable GPS]"
      },'')
    )
    beacon_update_infotext(meta)
    save_beacon(pos, meta)
  end,
  can_dig = function(pos,player)
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    local name = player:get_player_name()
    return inv:is_empty("main") and not minetest.is_protected(pos, name)
  end,
  after_dig_node = function(pos, oldnode, oldmetadata, player)
    ham_radio.delete_transmitter(pos)
  end,
});
