local UDP_GROUP = "225.0.0.37"
local UDP_PORT = 12345
local PROTOCOL_VERSION = 1  -- network protocal version, increase by 1 every time a capability change happens

local DISCONNECT_OK = 0
local DISCONNECT_VERSION_MISMATCH = 1

local EVENT_ROOM_INFO    = 1
local EVENT_PLAYER_JOIN  = 2
local EVENT_PLAYER_LEAVE = 3
local EVENT_TODO         = 233 -- TODO make more event

local libthreadpc = require("lib/threadpc")
local libsocket   = require("socket")
local libenet     = require("enet")
local binser      = require("lib/binser")
local Timer       = require("lib/hump.timer")
local Class       = require("lib/hump.class")
local Uuid        = require("lib/uuid")

function wrapf(f, firstarg)
	return function (...) return f(firstarg, ...) end
end

function simple_ds(class, template)
	class = class or {}
	class._template = template
	function class:init(...) 
		assert(#self._template == select(..., '#'), "Argument number not match.")
		for i,v in ipairs(self._template) do
			self[v] = select(..., i)
		end
	end
end

--+++++++++++++++++++++++++++++++++++++++

-- broadcast for finding rooms
local HandshakeDef      = simple_ds(binser.register(Class(), "nw_handshake"),
	{"version"})

local RoomInfoDef       = simple_ds(binser.register(Class(), "nw_room_info"),
	{"version", "name", "owner", "members"})

local ClientInfoDef     = simple_ds(binser.register(Class(), "nw_client_info"),
	{"uuid", "address"})

local EventDef          = simple_ds(binser.register(Class(), "nw_event"),
	{"type", "args"})

--+++++++++++++++++++++++++++++++++++++++

local pcproxy = libthreadpc("main->network", "network->main")

local dt  -- time elapse since last update
local last_update = 0
local function update_delta()
	local now = libsocket.gettime()
	dt = now - last_update
	last_update = now
	-- return dt
end

local timer  -- auto timer, clear every time enters a new state
local status
local network_states = {
--- Find room
	find = {
		find_room = function(self)
			self.udp:sendto(binser.s(HandshakeDef(PROTOCOL_VERSION)), UDP_GROUP, UDP_PORT)
		end,
		enter = function(self, last_status)
			local udp = assert(libsocket.udp())
			assert(udp:settimeout(0))  -- no blocking
			assert(udp:setsockname("*", 0))  -- bind to any port
			timer:every(1, wrapf(self.find_room, self))  -- send message every 1 second
		end,
		update = function(self)
			while 1 do
				local data = udp:receive()
				if data then
					local room_info = binser.d(data)
					pcproxy.found_room(room_info)
				else break end
			end
		end,
		exit = function(self)
			self.udp:close()
		end
	},

-- TODO send in game event
--- Host room or in room
	matchmake = {
		-- @param room_host_addr  if nil:          create a room
		--                        if enet address: address of host of room to join
		enter = function(self, last_status, room_info)
			self.host = libenet.host_create("*:0")
			self.address = self.host:get_socket_address()
			self.uuid = Uuid()
			self.self = ClientInfoDef(self.uuid, self.address)
			--- self.room.members   Room members, excluding yourself
			-- mapping  enet.peer => info = ClientInfoDef
			if room_info then
				self.is_owner = false
				-- connect to room
				self.room = room_info
			else
				-- create a new room
				self.is_owner = true
				local udp = assert(libsocket.udp())  -- udp socket, used to find server by multicast
				assert(udp:settimeout(0))  -- no blocking
				assert(udp:setsockname("*", UDP_PORT))  -- bind to PORT
				assert(udp:setoption("ip-add-membership", {multiaddr = UDP_GROUP, interface = "*"}))
				self.udp = udp
				-- TODO create room
				self.room = RoomInfoDef(PROTOCOL_VERSION, room_name, self.self, {})
			end
			-- self.is_owner = is_owner  -- is the owner of this room
		end,
		update = function(self)
			if self.is_owner then
				while 1 do
					local data, ip, port = udp:receivefrom()
					if data then
						local client_property = binser.d(data)
						-- IDEA maybe I can do something with client_property?
						udp:sendto(binser.s(RoomInfoDef(PROTOCOL_VERSION, self.room_name, self.self, self.members)))
					else break end
				end
			end
			local nw_event = self.host:service(0)
			while nw_event do
				local peer = nw_event.peer
				if nw_event.type == "receive" then
					if self.room.members[peer] then
						local gevent = binser.d(nw_event.data)
						-- TODO do things according to gevent.type
					end
				elseif nw_event.type == "connect" then
					local remote_pt_ver = nw_event.data
					-- protocal version check
					if remote_pt_ver == PROTOCOL_VERSION then
						-- peer:send(binser.s(EventDef(EVENT_ROOM_INFO, )))
						-- self.members[]
						-- peer:send(binser.s(EventDef())))
						-- if self.is_owner then
						-- 	self.host:broadcast(binser.s((EventDef())))
						-- 	-- TODO tell everyone else about our new member, let everyone add him/her
						-- end
					else
						peer:disconnect(DISCONNECT_VERSION_MISMATCH)
					end
				elseif nw_event.type == "disconnect" then
					if self.is_owner then
						-- TODO tell everyone else about the member's leave
					end
				else
					error("Invalid enet event type: ".. event.type ..".\nMay need to upgrade lua-enet.")
				end
				event = self.host:check_events()
			end
		end,
		exit = function(self)
			assert(udp:setoption("ip-drop-membership", {multiaddr = UDP_GROUP, interface = "*"}))
			self.udp:close()
			if self.is_owner then
				self.host:broadcast()
			end
		end
	},

--- Playing a match
	play = {
		enter = function(self, last_status)
			self.members = room_members
		end,
		update = function(self)

		end,
		exit = function(self)

		end
	}
}
for k,v in pairs(network_states) do
	v._name = k
end

function pcproxy.change_state(state_name, ...)
	local last_status = status
	if status then
		status:exit()
		timer = nil
	end
	status = network_states[state_name]
	if status then
		update_delta()  -- clear dt
		timer = Timer.new()
		status:enter(last_status, ...)
	end
end

function pcproxy.send_event(event_id, ...)
	
end


while 1 do
	pcproxy()
	if status then
		update_delta()
		timer:update(dt)
		status:update()
	end
	libsocket.sleep(0.001)
end
