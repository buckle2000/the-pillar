local aseprite = require("lib/aseprite")

Sprite = Class()

function Sprite:init(texture, animation)
	if is_s(texture) then
		texture = load_image(texture)
	end
	assert(is_u(texture, "Drawable"), "Please give a Drawble as argument.")
	self.texture = texture
	self.pos = vec()
	if is_u(texture, "Texture") or is_u(texture, "Text") then
		self.width, self.height = texture:getWidth(), texture:getHeight()
	end
	if is_s(animation) then
		animation = aseprite.Animation(animation)
	end
	self.animation = animation
	self.memory = {}  -- custom data
end

function Sprite:setxy(x, y)
	self.pos.x = x
	self.pos.y = y
	return self
end

-- function Sprite:setoffset(ox, oy)
-- 	self.ox = ox
-- 	self.oy = oy
-- 	return self
-- end

-- function Sprite:center_offset()
-- 	self.ox = self.width / 2
-- 	self.oy = self.height / 2
-- 	return self
-- end

function Sprite:draw()
	local x, y = self.pos:unpack()
	x, y = math.round(x), math.round(y)
	if self.quad then
		-- rot, sx, sy
		lg.draw(self.texture, self.quad, x, y)--, nil, nil, nil, self.ox, self.oy)
	else
		lg.draw(self.texture, x, y)--, nil, nil, nil, self.ox, self.oy)
	end
end

function Sprite:update(dt)
	local anim = self.animation
	if anim then
		anim:update(dt)
		self.quad = anim:get_quad()
	end
end

--+++++++++++++++++++++++++++++++++++++++

