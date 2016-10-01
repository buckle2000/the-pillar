Gamestate = require("lib/hump.gamestate")
vec       = require("lib/hump.vector")
Class     = require("lib/hump.class")
Timer     = require("lib/hump.timer")
lg        = love.graphics
require("utils")
require("core")

--- Load global variables
--- Initialize game
function love.load(arg)
	cFont = {}
	cFont.tiny   = load_font("04B_03", 8)
	cFont.normal = load_font("m5x7", 16)
	cFont.solid  = load_font("3Dventure", 16)
	cFont.hand   = load_font("pixel-love", 8)
	cFont.mono   = load_font("coders_crux", 16)
	cFont.retro  = load_font("Pixel-Musketeer", 14)
	table.seal(cFont)

	cState = {}
	cState.play    = require("state.play")
	cState.menu    = require("state.menu")
	cState.options = require("state.options")
	table.seal(cState)

	cColor = table.seal{
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

	game_width = 160
	game_height = 144
	game_scale = 4
	game_bgcolor = cColor[1]


	Gamestate.registerEvents()
	Gamestate.switch(cState.menu)
	Gamestate.switch(cState.menu)
end


function love.run()
	math.randomseed(os.time())
	love.math.setRandomSeed(os.time())
	love.load(arg)

	love.window.setMode(game_width * game_scale, game_height * game_scale)
	lg.setDefaultFilter('linear', 'nearest')
	lg.setLineStyle("rough")
	local game_canvas = lg.newCanvas(game_width, game_height)
	
	local dt = 0
	love.timer.step()
	while 1 do
		love.event.pump()
		for name, a,b,c,d,e,f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					return a
				end
			end
			love.handlers[name](a,b,c,d,e,f)
		end
		love.timer.step()
		dt = love.timer.getDelta()
		love.update(dt)
		if lg.isActive() then
			lg.setCanvas(game_canvas)
			lg.clear(game_bgcolor)
			lg.origin()
			love.draw()
			lg.setCanvas()
			lg.draw(game_canvas, 0, 0, 0, game_scale, game_scale)
			lg.present()
		end
		love.timer.sleep(0.001)
	end
end
