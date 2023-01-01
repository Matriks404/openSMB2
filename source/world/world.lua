local world = {}
world.current = 1

function world.init()
	world.count = 8 --TODO: Use this variable.

	world.level_count = 3
	world.level = 1

	world.area_count = 1

	world.area = 0

	world.area_widths = {} -- Array of area widths
	world.area_heights = {} -- Array of area heights
	world.area_backgrounds = {} -- Array of backgrounds (0 - Black, 1 - Light blue)
	world.area_music = {} -- Array of music (0 - Overworld, 1 - Underworld)
	world.area_tiles = {} -- Array of area tiles

	-- Start coordinates
	world.start_x = 0
	world.start_y = 0

	world.level_directory = ""
end

function world.reset()
	world.world = 1
	world.level = 1
end

function world.getLevelDirectory(directory)
	world_level_str = tostring(world.current).."-"..tostring(world.level)

	return directory.."/"..world_level_str.."/"
end

function world.doLoadFromLevelDirectory(directory)
	if not love.filesystem.getInfo(directory) then
		return false
	end

	if not love.filesystem.getInfo(directory.."settings.lua") then
		return false
	end

	return true
end

function world.loadLevel()
	base_level_dir = world.getLevelDirectory("levels")
	user_level_dir = world.getLevelDirectory("userlevels")

	if world.doLoadFromLevelDirectory(user_level_dir) then

		world.level_directory = user_level_dir
	elseif world.doLoadFromLevelDirectory(base_level_dir) then
		world.level_directory = base_level_dir
	else
		--TODO: This is just a placeholder, do something about that.
		love.window.showMessageBox("Error", "no valid level found!")
	end

	level_settings_data = love.filesystem.read(world.level_directory.."settings.lua")
	level_settings = TSerial.unpack(level_settings_data)

	-- Get level variables
	world.area_count = level_settings[1]
	world.start_x = level_settings[2]
	world.start_y = level_settings[3]

	for i=0, world.area_count - 1 do
	-- TODO: ???
		area_settings = level_settings[4 + i]

		-- Fill area width, height, background and music arrays
		world.area_widths[i] = area_settings[1]
		world.area_heights[i] = area_settings[2]
		world.area_backgrounds[i] = area_settings[3]
		world.area_music[i] = area_settings[4]
	end

	world.loadArea()
end

function world.loadArea()
	area_data = love.filesystem.read(world.level_directory..tostring(world.area))

	-- Check level background and set it
	if world.area_backgrounds[world.area] == 0 then
		graphics.setBackgroundColor("black")
	else
		graphics.setBackgroundColor("light_blue")
	end

	music.play()

	-- Fill tile data
	for i=0, (world.area_heights[world.area] / 16) - 1 do
		diff = i * (world.area_widths[world.area] / 16)
		world.area_tiles[i] = {}

		for j=0, (world.area_widths[world.area] / 16) - 1 do
				world.area_tiles[i][j] = string.byte(string.sub(area_data, diff + j + 1))
		end
	end

	--TODO: Add more!
end

function world.loadAllAreas()

end

function world.saveLevel()
	level_directory = world.getLevelDirectory("userlevels")

	if not love.filesystem.getInfo(level_directory) then
		love.filesystem.createDirectory(level_directory)
	end

	data = { world.area_count, world.start_x, world.start_y}

	for i=0, world.area_count - 1 do
		table.insert(data, {world.area_widths[i], world.area_heights[i], world.area_backgrounds[i], world.area_music[i] })
	end

	data = TSerial.pack(data, false, true)

	love.filesystem.write(level_directory.."settings.lua", data)

	world.saveArea()

	--TODO: Add more!
end

function world.saveArea()
	level_directory = world.getLevelDirectory("userlevels")

	area_file = level_directory..tostring(world.area)

	area_data = ""

	for i = 0, (world.area_heights[world.area] / 16) - 1 do
		for j = 0, (world.area_widths[world.area] / 16) - 1 do
			area_data = area_data..string.char(world.area_tiles[i][j])
		end
	end

	love.filesystem.write(area_file, area_data)
end

function world.saveAllAreas()

end

return world