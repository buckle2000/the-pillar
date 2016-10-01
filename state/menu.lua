local state = {}

local timer
local spr_title
local choices = {
	{"Play",    function() Gamestate.switch(cState.play) end},
	{"Options", function() Gamestate.switch(cState.options) end},
	{"Exit",    function() love.event.quit() end},
}
local spr_choices
local selected
local spr_avatar


function state:enter(previous, ...)
	selected = 1

	do
		spr_title = Sprite("title")
		local x = math.round((game_width - spr_title.width) / 2)
		local y = math.round(10)
		spr_title:setxy(x, y)
		timer = Timer()
		timer:script(function(wait)
			while 1 do
			    timer:tween(1, spr_title.pos, {y = y + 5}, 'in-out-quad')
			    wait(1.3)
			    timer:tween(1, spr_title.pos, {y = y}, 'in-out-quad')
			    wait(1.3)
			end
		end)
	end

	do
		local y = 64
		local font = cFont.normal
		local line_height = font:getHeight()
		spr_choices = {}
		for i,ch in ipairs(choices) do
			local text = lg.newText(font, ch[1])
			spr_choices[i] = Sprite(text):setxy(
				math.round((game_width - text:getWidth()) / 2),
				y)
			y = y + line_height
		end
	end

	spr_avatar = Sprite("authorx11")
	spr_avatar:setxy(game_width - spr_avatar.width, game_height - spr_avatar.height)

	game_bgcolor = cColor[14]
end


function state:update(dt)
	timer:update(dt)
end


function state:draw()
	spr_title:draw()
	spr_avatar:draw()
	set_color(16)
	for i,spr in ipairs(spr_choices) do
		if i == selected then
			set_color(4)
			spr:draw()
			set_color(16)
		else
			spr:draw()
		end
	end
end


function state:keypressed(key)
	if key == 'up' and selected > 1 then
		selected = selected - 1
	elseif key == 'down' and selected < #spr_choices then
		selected = selected + 1
	elseif key == 'return' then
		choices[selected][2]()
	end
end


function state:leave()
	spr_title = nil
	ch_sprites = nil
	spr_avatar = nil
	timer = nil
	collectgarbage()
end

return state
