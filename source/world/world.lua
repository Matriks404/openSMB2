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

function world.enter(world_no, level_no, area_no)
	if (not world[world_no]) then
		world[world_no] = {}
	end

	if (not world[world_no][level_no]) then
		world.load(world_no, level_no, area_no)
	end

	if (not area_no) then
		area_no = 0
	end

	world.current = world_no
	world.level = level_no
	world.area = area_no

	world.current_level = world[world_no][level_no]
	world.current_area = world[world_no][level_no][area_no]

	music.play()

	print("Entering (and rendering) area "..area_no.." of level "..world_no.."-"..level_no)
end

function world.load(world_no, level_no, area_no)
	base_level_dir = world.getLevelDirectory(world_no, level_no, "levels")
	user_level_dir = world.getLevelDirectory(world_no, level_no, "userlevels")

	if world.doLoadFromLevelDirectory(user_level_dir) then
		level_directory = user_level_dir
	elseif world.doLoadFromLevelDirectory(base_level_dir) then
		level_directory = base_level_dir
	else
		--TODO: This is just a placeholder, do something about that.
		love.window.showMessageBox("Error", "no valid level found!")
	end

	print("Loading level from "..level_directory)

	world.loadLevel(world_no, level_no, level_directory)

	if area_no then
		print("Loading area "..area_no.." from level "..world_no.."-"..level_no)

		world.loadArea(world_no, level_no, area_no, level_directory)
	else
		print("Loading all areas from level "..world_no.."-"..level_no)

		for area = 0, world[world_no][level_no].area_count - 1 do
			world.loadArea(world_no, level_no, area, level_directory)
		end
	end
end

function world.save(world_no, level_no)
	level_directory = world.getLevelDirectory(world_no, level_no, "userlevels")
	print("Saving level to "..level_directory)

	if not love.filesystem.getInfo(level_directory) then
		love.filesystem.createDirectory(level_directory)
	end

	world.saveLevel(world_no, level_no, level_directory)

	level = world[world_no][level_no]

	for area = 0, level.area_count - 1 do
		if level[area].modified or not love.filesystem.getInfo(level_directory..tostring(area)) then
			print("Saving area "..area)

			world.saveArea(world_no, level_no, area, level_directory)
		end
	end
end

function world.loadLevel(world_no, level_no, level_directory)
	world[world_no][level_no] = {}
	level = world[world_no][level_no]

	level_settings_data = love.filesystem.read(level_directory.."settings.lua")
	level_settings = TSerial.unpack(level_settings_data)

	-- Get level variables
	level.area_count = level_settings[1]
	level.start_x = level_settings[2]
	level.start_y = level_settings[3]

	for i = 0, level.area_count - 1 do
		area_settings = level_settings[4 + i]

		level[i] = {}
		area = world[world_no][level_no][i]

		-- Fill area width, height, background and music arrays
		area.width = area_settings[1]
		area.height = area_settings[2]
		area.background = area_settings[3]
		area.music = area_settings[4]
	end
end

function world.loadArea(world_no, level_no, area_no, level_directory)
	area = world[world_no][level_no][area_no]

	area_data = love.filesystem.read(level_directory..tostring(area_no))

	-- Check level background and set it
	if area.background == 0 then
		graphics.setBackgroundColor("black")
	else
		graphics.setBackgroundColor("light_blue")
	end


	height = area.height / 16
	width = area.width / 16

	if not area.tiles then
		area.tiles = {}

		-- Fill tile data
		for y = 0, height - 1 do
			diff = y * width
			area.tiles[y] = {}

			for x = 0, width - 1 do
				area.tiles[y][x] = string.byte(string.sub(area_data, diff + x + 1))
			end
		end
	end

	area.modified = false
end

function world.saveLevel(world_no, level_no, level_directory)
	level = world[world_no][level_no]

	data = { level.area_count, level.start_x, level.start_y}

	for i = 0, level.area_count - 1 do
		area = level[i]
		table.insert(data, {area.width, area.height, area.background, area.music })
	end

	data = TSerial.pack(data, false, true)

	love.filesystem.write(level_directory.."settings.lua", data)
end

function world.saveArea(world_no, level_no, area_no, level_directory)
	area_file = level_directory..tostring(area_no)

	area_data = ""
	area = world[world_no][level_no][area_no]

	for i = 0, (area.height / 16) - 1 do
		for j = 0, (area.width / 16) - 1 do
			area_data = area_data..string.char(area.tiles[i][j])
		end
	end

	love.filesystem.write(area_file, area_data)

	area.modified = false
end

return world