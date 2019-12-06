
minetest.register_node("ham_radio:transmitter", {
  description = "Ham Radio Transmitter",
  tiles = {"ham_radio_transmitter_top.png", "ham_radio_transmitter.png"},
  groups = {cracky=2,oddly_breakable_by_hand=2},
  sounds = default.node_sound_metal_defaults(),
  light_source = 5,
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string(
      "formspec", 
      "size[6,8]"..
      "field[0.25,0.25;3,1;frequency;Frequency;${frequency}]"..
      "button_exit[1.5,7.5;3,1;;Done]"
    )
    meta:set_string("infotext", '')
  end,
  on_receive_fields = function(pos, formname, fields, sender)
    if fields.quit ~= "true" then
      return
    end
    if fields.frequency ~= nil and fields.frequency ~= '' then
      local meta = minetest.get_meta(pos)
      meta:set_string("frequency", fields.frequency)
      meta:set_string("infotext", 'Frequency: '..fields.frequency)
      ham_radio.save_transmitter(fields.frequency, {
        pos = pos,
        broadcast_message = "Test Ham Radio Broadcast!"
      })
    end
  end,
  can_dig = function(pos,player)
    local meta = minetest.get_meta(pos);
    local inv = meta:get_inventory()
    local name = player:get_player_name()
    return inv:is_empty("main") and not minetest.is_protected(pos, name)
  end,
  after_dig_node = function(pos, oldnode, oldmetadata, player)
    ham_radio.delete_transmitter(oldmetadata.fields.frequency)
  end
});
