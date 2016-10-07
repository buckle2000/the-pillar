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

local libthreadpc = require("lib/threadpc")
local pcproxy = libthreadpc("network->main", "main->network")

--+++++++++++++++++++++++++++++++++++++++

local players
local remotes

local gevent = {}

function gevent.player_add(id)
	assert(not players[id], "Player uuid conflict: " .. id)
	players[id] = Player("human", true)
end

function gevent.player_spawn(id)
	assert(players[id], "No player: " .. id)
end

function gevent.player_move(id, v, pos)
	local player = players[id]
	player.v = v
	if pos then
		player.pos = pos
	end
end

-- function gevent.

-- Auto allocate number representations (id) for events
do
	local event_id = 1
	for convention_name, func in pairs(gevent) do
		gevent[event_id] = gevent[convention_name]
		local current_event_id = event_id
		gevent[convention_name] = function (...)
			-- THIS LINE let network thread send packet
			gevent[current_event_id](...)
		end
		event_id = event_id + 1
	end
end

--+++++++++++++++++++++++++++++++++++++++

local state = {}

local net_thread
local my_player_id

function state:enter(previous, ...)
	players = {}
	remotes = {}
	net_thread = love.thread.newThread("network.lua")
	net_thread:start()
	-- TODO better uuid
	my_player_id = '127.0.0.1' .. os.time()
	gevent.player_add(my_player_id)
end

local function ctrl_player(id)
	local dir = key_as_analog('left', 'right', 'up', 'down')
	gevent.player_move(id, dir * 50)
end

local function process_player(id)
	local player = players[id]
	-- TODO map
	-- TODO collision
	-- TODO attack
	-- TODO traps
end

function state:update(dt)
	ctrl_player(my_player_id)
	for k,v in pairs(players) do
		v:update(dt)
	end
	pcproxy()
	process_player(my_player_id)
end

function state:draw()
	for k,v in pairs(players) do
		v:draw()
	end
end

function state:leave()

end

return state
