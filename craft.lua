local circuit = 'default:mese_crystal'
local body = 'default:steel_ingot'
local wires = 'default:copper_ingot'
local glass = 'default:glass'
local antenna = wires
local battery = 'default:mese_crystal'

if minetest.get_modpath("basic_materials") then
  circuit = 'basic_materials:ic'
  body = 'basic_materials:plastic_sheet'
  wires = 'basic_materials:copper_wire'
  antenna = wires
  battery = 'basic_materials:energy_crystal_simple'
end

if minetest.get_modpath("technic") then
  antenna = 'technic:copper_coil'
  battery = 'technic:battery'
end

minetest.register_craftitem("ham_radio:circuit", {
  description = "Radio Circuit",
  inventory_image = "ham_radio_circuit.png",
})

minetest.register_craft({
  output = "ham_radio:circuit",
  recipe = {
    {circuit, wires, circuit},
    {body, battery, body},
  }
})

minetest.register_craft({
  output = "ham_radio:handheld_receiver",
  recipe = {
    {'', antenna, ''},
    {'','ham_radio:circuit', ''},
    {body, body, body}
  }
})

minetest.register_craft({
  output = "ham_radio:receiver",
  recipe = {
    {body, antenna, body},
    {glass,'ham_radio:circuit', glass},
    {body, body, body}
  }
})

minetest.register_craft({
  output = "ham_radio:transmitter",
  recipe = {
    {wires, antenna, wires},
    {glass, 'ham_radio:circuit', glass},
    {body, body, body}
  }
})

minetest.register_craft({
  output = "ham_radio:beacon",
  recipe = {
    {antenna, body},
    {wires, 'ham_radio:circuit'},
  }
})
