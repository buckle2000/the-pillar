local aseprite = require("lib/aseprite")

Sprite = Class()

function Sprite:init(texture, animation)
	if is_s(texture) then
		if animation == true then
			animation = aseprite.Animation(texture)
		end
		texture = load_image(texture)
	end
	if is_s(animation) then
		animation = aseprite.Animation(animation)
	end
	assert(is_u(texture, "Drawable"), "Please give a Drawble as argument.")
	self.texture = texture
	self.pos = vec()
	if is_u(texture, "Texture") or is_u(texture, "Text") then
		self.width, self.height = texture:getWidth(), texture:getHeight()
	end
	self.animation = animation
	self.memory = {}  -- custom data
end

function Sprite:draw()
	local x, y = self.pos:unpack()
	self:drawat(x, y)
end

function Sprite:drawat(x, y)
	if self.quad then
		-- rot, sx, sy
		lg.draw(self.texture, self.quad, x, y, self.rotation, nil, nil, self.ox, self.oy)
	else
		lg.draw(self.texture, x, y, self.rotation, nil, nil, self.ox, self.oy)
	end
end

function Sprite:update(dt)
	local anim = self.animation
	if anim then
		anim:update(dt)
		self.quad = anim:get_quad()
	end
end

function Sprite:setxy(x, y)
	self.pos.x = x
	self.pos.y = y
	return self
end

function Sprite:settag(name)
	self.animation:set_tag(name)
end

-- function Sprite:setoffset(ox, oy)
-- 	self.ox = ox
-- 	self.oy = oy
-- 	return self
-- end

function Sprite:center_offset()
	local anim = self.animation
	if anim then
		self.ox = anim.width / 2
		self.oy = anim.height / 2
	else
		self.ox = self.width / 2
		self.oy = self.height / 2
	end
	return self
end


--+++++++++++++++++++++++++++++++++++++++

