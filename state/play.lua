local Player = Class{__includes = Sprite}

function Player:init(...)
	Sprite.init(self, ...)
	self:center_offset()
	self._static = false
	self.alive = false
	-- self:revive()
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

function Player:hurt(damage)
	self.health = self.health - damage
	if self.health <= 0 then
		self.alive = false
	end
end

function Player:revive()
	self.alive = true
	self.health = 100
end

--+++++++++++++++++++++++++++++++++++++++

local mlib = require("lib/mlib")
local libthreadpc = require("lib/threadpc")
local pcproxy = libthreadpc("network->main", "main->network")

-- --+++++++++++++++++++++++++++++++++++++++

local spr_map
local col_mask  -- collision mask
local players
local remotes

local gevent = {}

function gevent.player_add(id)
	assert(not players[id], "Player uuid conflict: " .. id)
	players[id] = Player("human", true)
	players[id]:setxy(80, 72)
end

function gevent.player_spawn(id)
	assert(players[id], "No player: " .. id)
	players[id]:revive()
end

function gevent.player_move(id, v, pos)
	local player = players[id]
	player.v = v
	if pos then
		player.pos = pos
	end
end

function gevent.map_init(map_name)
	local a, b = load_map(map_name)
	col_mask = b
	spr_map = Sprite(a)
end

-- function gevent.

-- Auto allocate number representations (id) for events
do
	local gevent_names = {}
	for name,v in pairs(gevent) do
		table.insert(gevent_names, name)
	end
	local event_id = 1
	for i, name in pairs(gevent_names) do
		local func = gevent[name]
		gevent[event_id] = func
		gevent[name] = function (...)
			-- TODO THIS LINE let network thread send packet
			func(...)
		end
		event_id = event_id + 1
	end
end

--+++++++++++++++++++++++++++++++++++++++

local state = {}

local net_thread
local my_player_id

-- test
-- function stripey( x, y, r, g, b, a )
--    r = math.min(r * math.sin(x*100)*2, 255)
--    g = math.min(g * math.cos(x*150)*2, 255)
--    b = math.min(b * math.sin(x*50)*2, 255)
--    return r,g,b,a
-- end

function state:enter(previous, ...)
	players = {}
	remotes = {}
	net_thread = love.thread.newThread("network.lua")
	net_thread:start()
	-- TODO better uuid
	my_player_id = '127.0.0.1' .. os.time()
	gevent.map_init("round")
	gevent.player_add(my_player_id)
	gevent.player_spawn(my_player_id)
end

local function ctrl_player(id)
	local dir = key_as_analog('left', 'right', 'up', 'down')
	gevent.player_move(id, dir * 50)
end

local function process_player(id)
	local player = players[id]
	local x, y = player.pos:unpack()
	if col_mask:get(math.floor(x), math.floor(y)) == MAP_MASK_EMPTY then
		player:hurt(100000)
	end
	-- TODO map
	-- TODO collision
	-- TODO attack
	-- TODO traps
end

function state:update(dt)
	ctrl_player(my_player_id)
	for k,v in pairs(players) do
		if v.alive then
			v:update(dt)
		end
	end
	pcproxy()
	process_player(my_player_id)
end

function state:draw()
	spr_map:draw()
	for k,v in pairs(players) do
		if v.alive then
			v:draw()
		end
	end
end

function state:keypressed(key)
	if key == 'r' then
		self:enter()
	end
end

-- function state:leave()
	-- TODO
-- end

return state
