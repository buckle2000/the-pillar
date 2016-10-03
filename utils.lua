--################################################--
-------------------- MATH PATCH --------------------
--################################################--

function math.aabbsintersect( minA, maxA, minB, maxB )
	return minA.x <= maxB.x and
	       maxA.x >= minB.x and
	       maxA.y <= minB.y and
	       minA.y >= maxB.y
end

function math.clamp( n, l, u )
	return n < l and ( l ) or
	                 ( n > u and ( u ) or
	                             ( n ) )
end

function math.gcd( a, b )
	local t = 0
	while b ~= 0 do
		t = b
		b = a % b
		a = t
	end
	return a
end

function math.lerp( f, t, dt )
	return ( f + ( t - f ) * dt )
end

function math.nearestmult( n, mult )
	return math.round( n / mult ) * mult
end

function math.nearestpow2( n )
	return 2 ^ math.ceil( math.log( n ) / math.log( 2 ) )
end

math.phi = ( 1 + math.sqrt( 5 ) ) / 2

function math.pointinrect( px, py, x, y, width, height )
	return px >= x and
	       py >= y and
	       px < x + width and
	       py < y + height
end

function math.remap( n, inMin, inMax, outMin, outMax )
	return ( n / ( inMax - inMin ) ) * ( outMax - outMin ) + outMin
end

function math.round( n )
	return math.floor( n + 0.5 )
end

function math.rsign()
	if math.random()<0.5 then
		return -1
	else
		return 1
	end
end

function math.rfloat(l, u)
	return math.random() * (u-l) + l
end

--################################################--
------------------- TABLE PATCH --------------------
--################################################--

function table.foreach(t, apply, ...)
	for i,v in ipairs(t) do
		apply(v, ...)
	end
	return t
end

function table.contains(t, val)
	for i,v in ipairs(t) do
		if v == val then 
			return true
		end
	end
	return false
end

--- Seal a table
function table.seal(t)
    assert(is_t(t))
    local mt = getmetatable(t)
    if not mt then
        mt = {}
        setmetatable(t,mt)
    else
        assert(not mt.__newindex, 'This table already has __newindex metamethod.')
    end
    mt.__newindex = function(t,k,v)
        error(('Try to set closed table index <%s> with value <%s>'):format(k, v))
    end
    return t
end

--################################################--
------------------- TYPE DECTECT -------------------
--################################################--

function is_u(x, _type)
	return type(x)=="userdata" and (not _type or x:typeOf(_type))
end

function is_s(x)
	return type(x)=="string"
end

function is_n(x)
	return type(x)=="number"
end

function is_f(x)
	return type(x)=="function"
end

function is_t(x)
	return type(x)=="table"
end

--################################################--
-------------------- PATCH END ---------------------
--################################################--

function load_font(name, size)
	return love.graphics.newFont(path_to_font .. name .. ".ttf", size)
end

local loaded_images = {}

function load_image(name)
	if not loaded_images[name] then
		loaded_images[name] = love.graphics.newImage(path_to_image .. name .. ".png")
	end
	return loaded_images[name]
end

-- pixel precise drawing
function drawpx(drawable, x, y, scale)
	lg.draw(drawable, math.round(x), math.round(y),0 , scale, scale)
end

function pointpx(x, y)
	lg.points(x + 0.5, y + 0.5)
end

function wrapf(f, firstarg)
	return function (...) return f(firstarg, ...) end
end

function debug_image(width, height, fill_color)
	local image_data = love.image.newImageData(width, height)
	fill_color = fill_color or {255, 255, 255}
	for x=0,width-1 do
		for y=0,height-1 do
			image_data:setPixel(x, y, unpack(fill_color))
		end
	end
	return love.graphics.newImage(image_data)
end

local iskeydown = love.keyboard.isDown
function key_as_analog(left,right,up,down)
	local dx, dy = 0, 0
	if iskeydown(left)  then dx = dx - 1 end
	if iskeydown(right) then dx = dx + 1 end
	if iskeydown(up)    then dy = dy - 1 end
	if iskeydown(down)  then dy = dy + 1 end
	return vec(dx, dy):normalized()
end

-- https://github.com/stevedonovan/Penlight/blob/master/lua/pl/path.lua#L286
function format_path(path, sep)
	path = path:gsub('\\', '/')
	sep = sep or '/'
	local np_gen1,np_gen2  = '[^SEP]+SEP%.%.SEP?','SEP+%.?SEP'
	local np_pat1, np_pat2 = np_gen1:gsub('SEP',sep), np_gen2:gsub(sep,'/')
	local k

	repeat -- /./ -> /
		path,k = path:gsub(np_pat2,'/')
	until k == 0

	repeat -- A/../ -> (empty)
		path,k = path:gsub(np_pat1,'')
	until k == 0

	if path == '' then path = '.' end

	return path
end

function set_color(color)
	if is_n(color) then
		lg.setColor(cColor[color])
	elseif is_t(color) then
		lg.setColor(color)
	else
		lg.setColor(255, 255, 255)
	end
end

-- new text sprite
function new_txt(font, string)
	return Sprite(lg.newText(font, string))
end

reload_count = {}
local modify_time = {}
local file_cache = {}
function reload(filename, force)
	local complete_fn = filename:gsub('%.', '/') .. ".lua"
	local last_mod = love.filesystem.getLastModified(complete_fn)
	assert(last_mod, "File '"..filename.."' does not exist.")
	if force or last_mod ~= modify_time[filename] then
		modify_time[filename] = last_mod
		local success, result = pcall(love.filesystem.load, complete_fn)
		if success then
			file_cache[filename] = result()
		else
			error("Failed to reload file '"..filename.."'.")
		end
		reload_count[filename] = (reload_count[filename] or 0) + 1
	end
	return file_cache[filename]
end
