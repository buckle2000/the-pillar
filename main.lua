Gamestate = require("lib/hump.gamestate")
vec       = require("lib/hump.vector")
Class     = require("lib/hump.class")
Timer     = require("lib/hump.timer")
lg        = love.graphics


--- Load global variables
--- Initialize game
function love.load(arg)
	require("utils")
	reload("constant")

	cFont = {}
	cFont.tiny   = load_font("04B_03", 8)
	cFont.normal = load_font("m5x7", 16)
	cFont.solid  = load_font("3Dventure", 16)
	cFont.hand   = load_font("pixel-love", 8)
	cFont.mono   = load_font("coders_crux", 16)
	cFont.retro  = load_font("Pixel-Musketeer", 14)

	reload("constant", true)
	require("core")

	Gamestate.registerEvents()
	Gamestate.switch(reload("state/menu"))
end

function love.update(dt)
	reload("constant")
end

function love.run()
	math.randomseed(os.time())
	love.math.setRandomSeed(os.time())
	love.load(arg)

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
			set_color()
			lg.draw(game_canvas, 0, 0, 0, game_scale, game_scale)
			lg.present()
		end
		love.timer.sleep(0.001)
	end
end
