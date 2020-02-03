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
    if minetest.is_player(placer) then
      local name = placer:get_player_name()
      meta:set_string('operated_by', name)
      ham_radio.play_tuning_sound(placer)
    end
    meta:set_string("frequency", ham_radio.find_free_frequency(ham_radio.settings.beacon_frequency))
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
});
