local world = {}

function world.init()
	world.number = 1

	world.level_count = 3
	world.level = 1

	world.area_count = 1

	world.area = {}
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
	-- Fill area width, height and background arrays
		--areafile = love.filesystem.read(world.level_dir..tostring(area))

		area_settings = level_settings[4 + i]

		world.area_widths[i] = area_settings[1]
		world.area_heights[i] = area_settings[2]
		world.area_backgrounds[i] = area_settings[3]
		world.area_music[i] = area_settings[4]
	end

	world.loadArea()
end

function world.loadArea()
	area_data = love.filesystem.read(world.level_directory..tostring(world.area))
	--area_file = assert(io.open(love.filesystem.getSaveDirectory().."/"..world.level_directory..tostring(world.area)), "rb")
	--area_data = area_file:read("*all")

	-- Check level background and set it
	if world.area_backgrounds[world.area] == 0 then
		graphics.setBackgroundColor("black")
	else
		graphics.setBackgroundColor("light_blue")
	end

	world.playAreaMusic()

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

function world.saveLevel()
	level_directory = world.getLevelDirectory("userlevels")

	if not love.filesystem.getInfo(level_directory) then
		love.filesystem.createDirectory(world.level_dir)
	end

	data = { world.area_count, world.start_x, world.start_y}

	for i=0, world.area_count - 1 do
		table.insert(data, {world.area_widths[i], world.area_heights[i], world.area_backgrounds[i], world.area_music[i] })
	end

	data = TSerial.pack(data, false, true)
	love.filesystem.write(world.level_directory.."settings.lua", data)

	world.saveArea()

	--TODO: Add more!
end

function world.saveArea()
	level_directory = world.getLevelDirectory("userlevels")

	area_file = level_directory..tostring(world.area)

	--TODO: Remove
	--[[
	areadata = ""

	for i=0, (world.area_heights[world.area] / 16) - 1 do
	-- Fill file
		for j=0, (world.area_widths[world.area] / 16) - 1 do
			areatiles_str = utils.toPaddedString(world.area_tiles[i][j], 2)

			areadata = areadata..areatiles_str.."."
		end

		areadata = areadata.."\n"
	end

	love.filesystem.write(area_file, areadata)
	--]]



	area_data = ""

	for i = 0, (world.area_heights[world.area] / 16) - 1 do
		for j = 0, (world.area_widths[world.area] / 16) - 1 do
			area_data = area_data..string.char(world.area_tiles[i][j])
		end
	end

	love.filesystem.write(area_file, area_data)
end

function world.playAreaMusic()
	if debug.mute == false then
		if world.area_music[world.area] == 0 then
			music_overworld:play()

			music_underworld:stop()
			music_boss:stop()
		elseif world.area_music[world.area] == 1 then
			music_underworld:play()

			music_overworld:stop()
			music_boss:stop()
		else
			music_boss:play()

			music_overworld:stop()
			music_underworld:stop()
		end
	end
end

function world.stopAreaMusic()
	music_overworld:stop()
	music_underworld:stop()
	music_boss:stop()
end

function world.getLevelDirectory(directory)
	world_level_str = tostring(world.number).."-"..tostring(world.level)

	return directory.."/"..world_level_str.."/"
end

function world.doLoadFromLevelDirectory(directory)
	if not love.filesystem.getInfo(directory) then
		return false
	end

	if not love.filesystem.getInfo(directory.."settings.cfg") then
		return false
	end

	return true
end

return world