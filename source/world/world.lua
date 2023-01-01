local world = {}

world.count = 8 --TODO: Use this variable.

world.level_count = 3 --TODO: Use this variable.

function world.reset()
	world.current = 1
	world.level = 1
	world.area = 0
end

function world.getLevelDirectory(world_no, level_no, directory)
	world_level_str = tostring(world_no).."-"..tostring(level_no)

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

function world.setup(world_no, level_no, area_no)
	world.current = world_no
	world.current_level = world[world_no][level_no]
	world.current_area = world[world_no][level_no][area_no]

	music.play()
end

function world.loadAll(world_no, level_no)
	world.loadLevel(world_no, level_no)

	for area = 0, world[world_no][level_no].area_count - 1 do
		world.loadArea(world_no, level_no, area)
	end

	world.setup(world_no, level_no, 0)
end



function world.load(world_no, level_no, area_no)
	world.loadLevel(world_no, level_no)
	world.loadArea(world_no, level_no, area_no)

	world.setup(world_no, level_no, area_no)
end

function world.loadLevel(world_no, level_no, area_no)
	if (not world[world_no]) then
		world[world_no] = {}
	end

	world.level = level_no

	if (not world[world_no][level_no]) then
		base_level_dir = world.getLevelDirectory(world_no, level_no, "levels")
		user_level_dir = world.getLevelDirectory(world_no, level_no, "userlevels")

		world[world_no][level_no] = {}

		if world.doLoadFromLevelDirectory(user_level_dir) then
			world[world_no][level_no].directory = user_level_dir
		elseif world.doLoadFromLevelDirectory(base_level_dir) then
			world[world_no][level_no].directory = base_level_dir
		else
			--TODO: This is just a placeholder, do something about that.
			love.window.showMessageBox("Error", "no valid level found!")
		end

		level_settings_data = love.filesystem.read(world[world_no][level_no].directory.."settings.lua")
		level_settings = TSerial.unpack(level_settings_data)

		-- Get level variables
		world[world_no][level_no].area_count = level_settings[1]
		world[world_no][level_no].start_x = level_settings[2]
		world[world_no][level_no].start_y = level_settings[3]

		for area=0, world[world_no][level_no].area_count - 1 do
			area_settings = level_settings[4 + area]

			-- Fill area width, height, background and music arrays
			world[world_no][level_no][area] = {}
			world[world_no][level_no][area].width = area_settings[1]
			world[world_no][level_no][area].height = area_settings[2]
			world[world_no][level_no][area].background = area_settings[3]
			world[world_no][level_no][area].music = area_settings[4]
		end
	end
end

function world.loadArea(world_no, level_no, area_no)
	world.area = area_no

	area_data = love.filesystem.read(world[world_no][level_no].directory..tostring(area_no))

	-- Check level background and set it
	if world[world_no][level_no][area_no].background == 0 then
		graphics.setBackgroundColor("black")
	else
		graphics.setBackgroundColor("light_blue")
	end

	height = world[world_no][level_no][area_no].height / 16
	width = world[world_no][level_no][area_no].width / 16

	world[world_no][level_no][area_no].tiles = {}

	-- Fill tile data
	for y=0, height - 1 do
		diff = y * width
		world[world_no][level_no][area_no].tiles[y] = {}

		for x=0, width - 1 do
				world[world_no][level_no][area_no].tiles[y][x] = string.byte(string.sub(area_data, diff + x + 1))
		end
	end
end

function world.saveLevel()
	level_directory = world.getLevelDirectory("userlevels")

	if not love.filesystem.getInfo(level_directory) then
		love.filesystem.createDirectory(level_directory)
	end

	data = { world.area_count, world[world.current][world.level].start_x, world[world.current][world.level].start_y}

	for area=0, world.area_count - 1 do
		table.insert(data, {world[world.current][world.level][area].width, world[world.current][world.level][area].height, world[world.current][world.level][area].background, world[world.current][world.level][i].music })
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

	for i = 0, (world.current_area.height / 16) - 1 do
		for j = 0, (world.current_area.width / 16) - 1 do
			area_data = area_data..string.char(world.current_area.tiles[i][j])
		end
	end

	love.filesystem.write(area_file, area_data)
end

function world.saveAllAreas()

end

return world