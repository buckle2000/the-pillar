local Player = Class{__includes = Sprite}

function Player:init(...)
	Sprite.init(self, ...)
	self:center_offset()
	self._static = false
end

function Player:setv(vx, vy)
	local v = self.v
	v.x, v.y = vx or 0, vy or 0
	return self
end

function Player:update(dt)
	if self.v == vec.zero then
		if not self._static then
			self._static = true
			self:settag("stand")
		end
	else
		self.pos = self.pos + self.v * dt
		self.rotation = self.v:angleTo()
		if self._static then
			self._static = false
			self:settag("run")
		end
	end
	Sprite.update(self, dt)
end

--+++++++++++++++++++++++++++++++++++++++

local state = {}

local players
local my_player_id
local function add_player(id)
	id = id or '127.0.0.1' .. os.time()
	assert(not players[id], "Player uuid conflict: " .. id)
	players[id] = Player("human", true)
	return id
end

function state:enter(previous, ...)
	players = {}
	my_player_id = add_player()
end


function state:update(dt)
	local dir = key_as_analog('left', 'right', 'up', 'down')
	local me = players[my_player_id]
	me.v = dir * 20
	for k,v in pairs(players) do
		v:update(dt)
	end
end

function state:draw()
	for k,v in pairs(players) do
		v:draw()
	end
end

function state:leave()

end

return state
