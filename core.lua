Sprite = Class()

function Sprite:init(texture)
	if is_s(texture) then
		texture = load_image(texture)
	end
	assert(is_u(texture, "Drawable"))
	self.texture = texture
	self.pos = vec()
	if is_u(texture, "Texture") then
		self.width, self.height = self.texture:getDimensions()
	end
	self.memory = {}  -- custom data
end

function Sprite:setxy(x, y)
	self.pos.x = x
	self.pos.y = y
	return self
end

function Sprite:draw()
	local x, y = self.pos:unpack()
	lg.draw(self.texture, math.round(x), math.round(y))
	return self
end
