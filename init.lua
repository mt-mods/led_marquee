-- simple LED marquee mod
-- by Vanessa Dannenberg

led_marquee = {}

local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

local marquee_cbox = {
	type = "fixed",
	fixed = { -16/32, -8/16, 15/32, 16/32, 8/16, 16/32 }
}

-- the following functions based on the so-named ones in Jeija's digilines mod

local reset_meta = function(pos)
	minetest.get_meta(pos):set_string("formspec", "field[channel;Channel;${channel}]")
end

local on_digiline_receive_std = function(pos, node, channel, msg)
	local meta = minetest.get_meta(pos)
	local setchan = meta:get_string("channel")
	if setchan ~= channel then return end
	local num = tonumber(msg)
	if msg == "colon" or msg == "period" or msg == "off" or (num and (num >= 0 and num <= 9)) then
			minetest.swap_node(pos, { name = "led_marquee:marquee_"..msg, param2 = node.param2})
	end
end

-- the nodes:

local fdir_to_right = {
	{  1,  0 },
	{  0, -1 },
	{ -1,  0 },
	{  0,  1 },
}

local padding = " "
local allon = string.char(128)
for i = 1, 64 do
	padding = padding.." "
	allon = allon..string.char(128)
end

local display_string = function(pos, channel, string)
	if string == "off_multi" then
		string = ""
	elseif string == "allon_multi" then
		string = allon
	end
	local padded_string = string.sub(string..padding, 1, 64)
	local fdir = minetest.get_node(pos).param2 % 4
	local pos2 = pos
	for i = 1, 64 do
		local node = minetest.get_node(pos2)
		local meta = minetest.get_meta(pos2)
		local setchan = meta:get_string("channel")
		if not string.match(node.name, "led_marquee:char_") or (setchan ~= nil and setchan ~= "" and setchan ~= channel) then break end
		local asc = string.byte(padded_string, i, i)
		if (node.param2 % 4) == fdir and asc > 31 and asc < 130 then
			minetest.swap_node(pos2, { name = "led_marquee:char_"..asc, param2 = node.param2})
		end
		pos2.x = pos2.x + fdir_to_right[fdir+1][1]
		pos2.z = pos2.z + fdir_to_right[fdir+1][2]
	end
end

local on_digiline_receive_string = function(pos, node, channel, msg)
	local meta = minetest.get_meta(pos)
	local setchan = meta:get_string("channel")
	if setchan ~= channel then return end
	if msg and msg ~= "" and type(msg) == "string" then
		if string.len(msg) > 1 then
			if msg == "off" then
				minetest.swap_node(pos, { name = "led_marquee:char_32", param2 = node.param2})
			elseif msg == "colon" then
				minetest.swap_node(pos, { name = "led_marquee:char_58", param2 = node.param2})
			elseif msg == "period" then
				minetest.swap_node(pos, { name = "led_marquee:char_46", param2 = node.param2})
			elseif msg == "del" then
				minetest.swap_node(pos, { name = "led_marquee:char_127", param2 = node.param2})
			elseif msg == "allon" then
				minetest.swap_node(pos, { name = "led_marquee:char_128", param2 = node.param2})
			elseif msg == "cursor" then
				minetest.swap_node(pos, { name = "led_marquee:char_129", param2 = node.param2})
			else
				display_string(pos, channel, msg)
			end
		else
			local asc = string.byte(msg)
			if asc > 31 and asc < 130 then
				minetest.swap_node(pos, { name = "led_marquee:char_"..asc, param2 = node.param2})
			elseif msg == "get" then -- get value as ASCII numerical value
				digiline:receptor_send(pos, digiline.rules.default, channel, tonumber(string.match(minetest.get_node(pos).name,"led_marquee:char_(.+)"))) -- wonderfully horrible string manipulaiton
			elseif msg == "getstr" then -- get actual char
				digiline:receptor_send(pos, digiline.rules.default, channel, string.char(tonumber(string.match(minetest.get_node(pos).name,"led_marquee:char_(.+)"))))
			end
		end
	elseif msg and type(msg) == "number" then
		if msg == 0 then
			minetest.swap_node(pos, { name = "led_marquee:char_32", param2 = node.param2})
		elseif msg > 31 and alnum_chars[msg - 31] ~= nil then
			minetest.swap_node(pos, { name = "led_marquee:char_"..tostring(msg), param2 = node.param2})
		end
	end
end

for i = 32, 129 do
	local groups = { cracky = 2, not_in_creative_inventory = 1}
	local light = LIGHT_MAX-2
	local description = S("Alphanumeric LED marquee panel ("..i..")")

	if i == 32 then
		groups = {cracky = 2}
		light = nil
		description = S("Alphanumeric LED marquee panel")
	end

	minetest.register_node("led_marquee:char_"..i, {
		description = description,
		drawtype = "mesh",
		mesh = "led_marquee.obj",
		tiles = {
			"led_marquee_base.png",
			"led_marquee_leds_off.png",
			{ name="led_marquee_char_"..i..".png", color="0xffff0000"},
		},
		use_texture_alpha = true,
		groups = groups,
		paramtype = "light",
		paramtype2 = "colorfacedir",
		light_source = light,
		selection_box = marquee_cbox,
		collision_box = marquee_cbox,
		on_construct = function(pos)
			reset_meta(pos)
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			if (fields.channel) then
				minetest.get_meta(pos):set_string("channel", fields.channel)
			end
		end,
		digiline = {
			receptor = {},
			effector = {
				action = on_digiline_receive_string,
			},
		},
		drop = "led_marquee:char_32"
	})
end

-- crafts


minetest.register_craft({
	output = "led_marquee:char_32 4",
	recipe = {
		{ "", "default:glass", "" },
		{ "default:glass", "default:sign_wall", "default:glass" },
		{ "default:glass", "default:mese_crystal", "default:glass" }
	},
})

