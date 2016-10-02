cColor = {
	{ 20,  12,  28},
	{ 68,  36,  52},
	{ 48,  52, 109},
	{ 78,  74,  78},
	{133,  76,  48},
	{ 52, 101,  36},
	{208,  70,  72},
	{117, 113,  97},
	{ 89, 125, 206},
	{210, 125,  44},
	{133, 149, 161},
	{109, 170,  44},
	{210, 170, 153},
	{109, 194, 202},
	{218, 212,  94},
	{222, 238, 214},
}

if game_already_loaded then
	-- Load the second time
	debug_font = cFont.tiny
else
	game_already_loaded = true
end

debug_font_color = cColor[1]
-- default_fot_size = 14

game_version = "v0.1"
game_width   = 160
game_height  = 144
game_scale   = 4
-- game_bgcolor = cColor[1]  -- background color, you can set this arbitrarily in code

path_to_image = "assets/image/"
path_to_font = "assets/font/"



function love.conf(t)
	t.version = "0.10.1"
	t.console = true
	t.window.title = "The Pillar"
	t.window.width = game_width * game_scale
	t.window.height = game_height * game_scale
	love._config = t
end
