
ham_radio.transmitter_update_infotext = function(meta)
  local frequency = meta:get_string("frequency")
  local broadcast_message = meta:get_string("broadcast_message")
  if frequency == "" then
    frequency = "--"
    broadcast_message = ""
  end
  local infotext = {'Frequency: ', frequency}
  if broadcast_message ~= "" then
    table.insert(infotext, '\nBroadcast: "')
    table.insert(infotext, broadcast_message)
    table.insert(infotext, '"')
  end
  meta:set_string("infotext", table.concat(infotext, ''))
end

minetest.register_node("ham_radio:transmitter", {
  description = "Radio Transmitter",
  tiles = {
	  "ham_radio_transmitter_top.png",
	  "ham_radio_transmitter_top.png",
	  "ham_radio_transmitter_side.png",
	  "ham_radio_transmitter_side.png",
	  "ham_radio_transmitter_side.png",
	  "ham_radio_transmitter_front.png"
  },
  groups = {cracky=2,oddly_breakable_by_hand=2},
  sounds = default.node_sound_metal_defaults(),
  paramtype2 = "facedir",
  light_source = 3,
  after_place_node = function(pos, placer)
    local meta = minetest.get_meta(pos);
    local name = placer:get_player_name()
    meta:set_string('operated_by', name)
    meta:set_string('broadcast_message', "")
    meta:set_string("formspec",
      table.concat({
        "size[7,5]",
        "image[0,0;1,1;ham_radio_transmitter_front.png]",
        "label[1,0;Transmitter operated by: ",minetest.formspec_escape(name),"]",
        "field[0.25,2;7,1;frequency;Frequency;${frequency}]",
        "tooltip[frequency;Integer number ",
          ham_radio.settings.frequency.min,"-",
          ham_radio.settings.frequency.max, "]",
        "field[0.25,3.5;7,1;broadcast_message;RDS message;${broadcast_message}]",
        "button_exit[2,4.5;3,1;;Done]"
      },'')
    )
    meta:set_string("infotext", '')
  end,
  on_receive_fields = function(pos, formname, fields, sender)
    if not minetest.is_player(sender) then
      return
    end

    if (
      fields.quit ~= "true"
      or minetest.is_protected(pos, sender:get_player_name()) 
      or not ham_radio.validate_frequency(fields.frequency)
    ) then
      return
    end

    local meta = minetest.get_meta(pos)
    meta:set_string("frequency", fields.frequency)
    meta:set_string("broadcast_message", fields.broadcast_message)
    ham_radio.transmitter_update_infotext(meta)
    ham_radio.save_transmitter(pos, meta)
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
  -- digiline
  digiline = {
    receptor = {action = function() end},
    effector = {
      action = ham_radio.digiline_effector
    },
  },
});
