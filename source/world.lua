data = require "source/data"

local world = {}

world.count = 8 --TODO: Use this variable.

world.level_count = 3 --TODO: Use this variable.

world.types = {}
world.types["horizontal"] = { short_name = "HRZ" }
world.types["vertical"] = { short_name = "VRT" }

function world.reset()
	world.current = 1
	world.level = 1
	world.area = 0
end

function world.getLevelDirectory(world_no, level_no, directory)
	local world_level_str = tostring(world_no).."-"..tostring(level_no)

	return directory.."/"..world_level_str.."/"
end

function world.isGoodLevel(directory)
	print("Level correctness check for level in `"..directory.."` directory")

	if not love.filesystem.getInfo(directory) then
		print("\tNo level directory!")

		return false
	end

	local level_settings_file = directory.."settings.lua"

	if not love.filesystem.getInfo(level_settings_file) then
		print("\tNo level settings file!")

		return false
	end

	local level_settings_data = love.filesystem.read(level_settings_file)
	local level_settings = TSerial.unpack(level_settings_data)

	if not level_settings then
		print("\tInvalid level settings file!")
		return false
	end

	local area_count = level_settings[1]
	local start_x = level_settings[2]
	local start_y = level_settings[3]

	if not data.isGoodInteger(area_count, 1) then
		print("\tInvalid area count: "..area_count)

		return false
	end

	if not data.isGoodInteger(start_x, 0) then
		print("\tInvalid starting X position: "..start_x)

		return false
	end

	if not data.isGoodInteger(start_y, 0) then
		print("\tInvalid starting Y position: "..start_y)

		return false
	end

	for i = 0, area_count - 1 do
		local index = 4 + i

		if not level_settings[index] then
			print("\tNo settings for expected area "..i)

			return false
		end

		local area_settings = level_settings[index]

		local type = area_settings[1]
		local width = area_settings[2]
		local height = area_settings[3]
		local background = area_settings[4]
		local music_track = area_settings[5]

		if not type then
			print("\tType is not defined for area "..i)

			return false
		end

		if not world.types[type] then
			print("\tType '"..type.."' is not valid for area "..i)

			return false
		end

		if not data.isGoodDivisibleInteger(width, 16, 16) then
			print("\tArea width "..width.." is not valid for area "..i)

			return false
		end

		if i == 0 and start_x >= width then
			local max = width - 1

			print("\tStarting X position "..start_x.." is bigger than maximum "..max.." for area "..i)

			return false
		end

		if not data.isGoodDivisibleInteger(height, 16, 16) then
			print("\tArea height "..height.." is not valid for area "..i)

			return false
		end

		if i == 0 and start_y >= height then
			local max = height - 1

			print("\tStarting Y position "..start_y.." is bigger than maximum "..max.." for area "..i)

			return false
		end

		if not background then
			print("\tBackground is not defined for area "..i)

			return false
		end

		if not graphics.bg[background] then
			print("\tBackground '"..background.."' is not valid for area "..i)

			return false
		end

		if not music then
			print("\tMusic is not defined for area "..i)

			return false
		end

		if not music.m[music_track] then
			print("\tMusic '"..music_track.."' is not valid for area "..i)

			return false
		end

		local area_file_info = love.filesystem.getInfo(directory..i)

		if not area_file_info then
			print("\tNo file for area "..i)

			return false
		end

		local size = area_file_info.size
		local expected_size = (width / 16) * (height / 16)

		if size ~= expected_size then
			print("\tInvalid file size for area "..i..", expected: "..expected_size.." B, got: "..size.." B")

			return false
		end
	end

	print("\tEverything is OK!")
	return true
end

function world.checkAreaSizeValidity(world_no, level_no, area_no)
	area = world[world_no][level_no][area_no]

	if area.type == "horizontal" then
		area.valid_width = area.width >= 16
		area.valid_height = area.height >= 16 and area.height <= 240

	elseif area.type == "vertical" then
		area.valid_width = area.width == 256
		area.valid_height = area.height >= 16
	end

	area.valid_size = area.valid_width and area.valid_height
end

function world.update(world_no, level_no, area_no)
	world.current = world_no
	world.level = level_no
	world.area = area_no

	world.current_level = world[world_no][level_no]
	world.current_area = world[world_no][level_no][area_no]

	world.checkAreaSizeValidity(world_no, level_no, area_no)
end

function world.enter(world_no, level_no, area_no)
	if (not world[world_no]) then
		world[world_no] = {}
	end

	if (not world[world_no][level_no]) then
		world.load(world_no, level_no, area_no)
	end

	if (not world[world_no][level_no]) then
		return
	end

	local area_no = area_no or 0

	world.update(world_no, level_no, area_no)

	music.play(world[world_no][level_no][area_no].music)

	-- Check level background and set it
	graphics.setBackgroundColor(world.current_area.background)

	print("Entering (and rendering) area "..area_no.." of level "..world_no.."-"..level_no)
end

function world.isLevelModified(world_no, level_no)
	level = world[world_no][level_no]

	if level.modified then
		return true
	end

	for area = 0, level.area_count - 1 do
		if level[area].modified then
			return true
		end
	end
end

function world.load(world_no, level_no, area_no)
	local level_directory

	local base_level_dir = world.getLevelDirectory(world_no, level_no, "levels")
	local user_level_dir = world.getLevelDirectory(world_no, level_no, "userlevels")

	if world.isGoodLevel(user_level_dir) then
		level_directory = user_level_dir
	elseif world.isGoodLevel(base_level_dir) then
		level_directory = base_level_dir
	else
		--TODO: This is just a placeholder, do something about that.
		love.window.showMessageBox("Error", "No valid level found! Check the console for details.", "error")

		return
	end

	print("\nLoading level from `"..level_directory.."` directory")

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
	local level = world[world_no][level_no]

	for area = 0, level.area_count - 1 do
		world.checkAreaSizeValidity(world_no, level_no, area)

		if not level[area].valid_size then
			local msg = "Invalid size for area "..area.."!"..
			"\nPlease make sure that the area size is valid for specified area type."..
			"\nYou can also press 'R' key in the editor to resize the area to valid size, although note that any data outside of legal area will be irreversibly deleted."

			love.window.showMessageBox("Error", msg, "error")

			return
		end
	end

	local level_directory = world.getLevelDirectory(world_no, level_no, "userlevels")
	print("Saving level to "..level_directory)

	if not love.filesystem.getInfo(level_directory) then
		love.filesystem.createDirectory(level_directory)
	end

	world.saveLevel(world_no, level_no, level_directory)

	for area = 0, level.area_count - 1 do
		if level[area].modified or not love.filesystem.getInfo(level_directory..tostring(area)) then
			print("Saving area "..area)

			world.saveArea(world_no, level_no, area, level_directory)
		end
	end

	love.window.showMessageBox("Info", "Level was saved to "..level_directory, "info")
end

function world.loadLevel(world_no, level_no, level_directory)
	world[world_no][level_no] = {}
	level = world[world_no][level_no]

	local level_settings_file = love.filesystem.read(level_directory.."settings.lua")
	local level_settings = TSerial.unpack(level_settings_file)

	level.area_count = level_settings[1]
	level.start_x = level_settings[2]
	level.start_y = level_settings[3]

	for i = 0, level.area_count - 1 do
		local area_settings = level_settings[4 + i]

		level[i] = {}
		area = world[world_no][level_no][i]

		area.type = area_settings[1]
		area.width = area_settings[2]
		area.height = area_settings[3]
		area.background = area_settings[4]
		area.music = area_settings[5]
	end
end

function world.loadArea(world_no, level_no, area_no, level_directory)
	area = world[world_no][level_no][area_no]

	local area_data = love.filesystem.read(level_directory..tostring(area_no))

	local height = area.height / 16
	local width = area.width / 16

	if not area.tiles then
		area.tiles = {}

		-- Fill tile data
		for y = 0, height - 1 do
			local diff = y * width
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

	local level_settings_file = level_directory.."settings.lua"
	local data = { level.area_count, level.start_x, level.start_y}

	for i = 0, level.area_count - 1 do
		area = level[i]
		table.insert(data, {area.type, area.width, area.height, area.background, area.music })
	end

	data = TSerial.pack(data, false, true)

	love.filesystem.write(level_settings_file, data)
end

function world.saveArea(world_no, level_no, area_no, level_directory)
	area = world[world_no][level_no][area_no]

	local area_file = level_directory..tostring(area_no)
	local area_data = ""

	for i = 0, (area.height / 16) - 1 do
		for j = 0, (area.width / 16) - 1 do
			area_data = area_data..string.char(area.tiles[i][j])
		end
	end

	love.filesystem.write(area_file, area_data)

	area.modified = false
end

return world