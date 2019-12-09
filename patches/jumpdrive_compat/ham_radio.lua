
jumpdrive.ham_radio_compat = function(from, to)
	local meta = minetest.get_meta(to)
	ham_radio.delete_transmitter(from)
	ham_radio.save_transmitter(to, meta)
end

