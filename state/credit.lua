local state = {}

-- local spr_fonts
-- local function txt(font, fontname, author)
-- 	return new_txt(fontname .. " by " .. author)
-- end

function state:enter()
	-- spr_fonts = {
	-- 	txt(cFont.solid,   "3Dventure",        "Aaron D. Chand"),
	-- 	txt(cFont.tiny,    "04b03",            "04"),
	-- 	txt(cFont.mono,    "Coder’s Crux",     "NALGames"),
	-- 	txt(cFont.normal,  "m5x7",             "Daniel Linssen"),
	-- 	txt(cFont.hand,    "Pixel Love",       "Mirz123"),
	-- 	txt(cFont.retro,   "Pixel Musketeer",  "Neale Davidson"),
	-- }
	-- do
	-- 	local y = 0
	-- 	for i,v in ipairs(spr_fonts) do
	-- 		v:setxy(0, y)
	-- 		y = y + 16
	-- 	end
	-- end
end

function state:update(dt)
end

function state:draw()
	-- for i,v in ipairs(spr_fonts) do
	-- 	v:draw()
	-- end
end

return state
