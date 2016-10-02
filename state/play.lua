local Player = Class{__includes = Sprite}

function Player:init(texture)
	Sprite.init(self, texture)
end

function Player:setv(vx, vy)
	local v = self.v
	v.x, v.y = vx, vy
	return self
end

function Player:update(dt)
	Sprite.update(self, dt)
	self.pos = self.pos + self.v * dt
end

--+++++++++++++++++++++++++++++++++++++++

local state = {}

local players
local my_player_id
local function add_player(id)
	id = id or '127.0.0.1' .. os.time()
	assert(not players[id], "Player uuid conflict: " .. id)
	players[id] = Player("b2x11")
	return id
end

function state:enter(previous, ...)
	players = {}
	my_player_id = add_player()
end


function state:update(dt)
	local kx, ky = key_as_analog('left', 'right', 'up', 'down')
	local me = players[my_player_id]
	me.v = vec(kx, ky) * 20
	me:update(dt)
end

function state:draw()
	for k,v in pairs(players) do
		v:draw()
	end
end

function state:leave()

end

return state
