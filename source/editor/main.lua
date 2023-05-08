local editor = {}

editor.img = {}

editor.check = require "source/editor/check"
editor.draw = require "source/editor/draw"
editor.view = require "source/editor/view"

-- Level editor variables
editor.option = "select" -- Editor option (select, edit)
editor.tile = 1

editor.mode = "normal" -- Editor mode (normal, start)

editor.modes = {
	["normal"] = { short_name = "N" },
	["start"] = { short_name = "S" }
}

-- Editor cursor coordinates
editor.cursor_x = 0
editor.cursor_y = 0

function editor.loadImages()
	local directory = "resources/images/leveleditor/"

	-- Mandatory, but expected
	editor.img["16x16_empty"] = resources.loadImage(directory.."16x16.png")
	editor.img["16x16_cursor"] = resources.loadImage(directory.."16x16_cursor.png")
	editor.img["sp"] = resources.loadImage(directory.."starting_point.png")
	editor.img["sp_select"] = resources.loadImage(directory.."starting_point_select.png")
	--editor.img["border_arrow"] = resources.loadImage(directory.."border_arrow.png")
end

function editor.reset()
	editor.option = "select"
	editor.mode = "normal"
	editor.tile = 1
end

function editor.openLevel()
	world.enter(world_no, level_no)

	if world[world_no][level_no] then
		window.resizable = true
		window.update()

		editor.option = "edit"

		editor.view.update()

		debugging.info = false
	end
end

function editor.loadLevel()
	world.load(world.current, world.level)

	world.update(world.current, world.level, world.area)
end

function editor.saveLevel()
	world.save(world.current, world.level)
end

function editor.playLevel()
	world.save(world.current, world.level)

	if world[world.current][world.level][world.area].valid_size then
		character.reset()

		state.set("character_select")
		world.area = 1

		window.resizable = false
		window.update()
	end
end

function editor.removeArea(area)
	local level = world.current_level

	if #level == 1 then
		local msgbox_name = "Removing area "..world.area
		local msgbox_msg = "You can't remove the last area from the level!"

		love.window.showMessageBox(msgbox_name, msgbox_msg, "error")

		return
	end

	local msgbox_name = "Removing area "..world.area
	local msgbox_msg = "Are you sure you want to remove the area "..world.area.."?"
	local msgbox_buttons = { "Proceed", "Cancel" }

	local button = love.window.showMessageBox(msgbox_name, msgbox_msg, msgbox_buttons, "warning")

	if button ~= 1 then
		return
	end

	print("Removing area "..world.area)

	level[world.area] = {}

	-- Reset starting position if we remove the first area of the level.
	if world.area == 0 then
		level.start_x = 0
		level.start_y = 0
	end

	for i = world.area, #level - 1 do
		level[i] = level[i + 1]
		level[i].modified = true
	end

	if world.area >= #level then
		world.area = world.area - 1
	end

	level[#level] = nil
	level.modified = true

	editor.goToArea(world.current, world.level, world.area)
end

function editor.addArea()
	local new_area = world.area + 1

	local msgbox_name = "Adding area "..new_area

	local msgbox_msg = "Are you sure you want to add new area with ID "..new_area.."?"..
	"\nIf there are any areas after the currently edited one their ID will be increased by one."

	local msgbox_buttons = { "Proceed", "Cancel" }

	local button = love.window.showMessageBox(msgbox_name, msgbox_msg, msgbox_buttons, "warning")

	if button ~= 1 then
		return
	end

	local level = world.current_level

	print("Adding new area "..new_area)

	for i = #level, new_area, -1 do
		level[i + 1] = level[i]
		level[i + 1].modified = true
	end

	level[new_area] = {}
	level[new_area].tiles = {}

	for k, v in pairs(world.defaults) do
		level[new_area][k] = v
	end

	local area = level[new_area]

	for y = 0, (area.height / 16) - 1 do
		area.tiles[y] = {}

		for x = 0, (area.width / 16) - 1 do
			area.tiles[y][x] = 0
		end
	end

	area.modified = true
	level.modified = true

	editor.goToArea(world.current, world.level, new_area)

end

function editor.goToArea(world_no, level_no, area_no)
	if area_no ~= 0 and editor.mode == "start" then
		editor.mode = "normal"
	end

	world.enter(world_no, level_no, area_no)

	editor.view.reset()
	editor.view.update()
end

function editor.goToPreviousArea()
	if #world.current_level > 1 then
		if world.area > 1 then
			world.area = world.area - 1
		else
			world.area = #world.current_level
		end

		editor.goToArea(world.current, world.level, world.area)
	end
end

function editor.goToNextArea()
	if #world.current_level > 1 then
		if world.area < #world.current_level then
			world.area = world.area + 1
		else
			world.area = 1
		end

		editor.goToArea(world.current, world.level, world.area)
	end
end

function editor.changeMode()
	if world.area == 1 and editor.mode == "normal" then
		editor.mode = "start"
	else
		editor.mode = "normal"

		editor.view.alignCursor()
	end
end

function editor.changeView()
	if editor.view.name == "normal" then
		editor.view.name = "detailed"
	else
		editor.view.name = "normal"
	end
end

function editor.quit()
	if world.isLevelModified(world.current, world.level) then
		world[world_no][level_no] = nil
	end

	editor.reset()
	editor.view.reset()

	window.resizable = false
	window.update()

	graphics.setBackgroundColor("black")
	game_resources.music.stopAll()
end

function editor.quitToTitleScreen()
	state.set("title")
end


function editor.moveCursor(x, y)
	editor.cursor_x = editor.cursor_x + x
	editor.cursor_y = editor.cursor_y + y

	editor.check.cursorBounds()
	editor.check.viewBounds()
end


function editor.moveStartingPosition(x, y)
	local level = world.current_level

	level.start_x = level.start_x + x
	level.start_y = level.start_y + y

	editor.check.startingPositionBounds()
	editor.view.alignToStartingPosition()

	world.current_level.modified = true
end

function editor.updateType()
	--TODO: This is dumb.
	if world.current_area.type == "horizontal" then
		world.current_area.type = "vertical"
	else
		world.current_area.type = "horizontal"
	end

	world.checkAreaSizeValidity(world.current, world.level, world.area)

	world.current_level.modified = true
end

function editor.updateBackground()
	--TODO: This is dumb.
	if world.current_area.background == "black" then
		world.current_area.background = "light_blue"
	else
		world.current_area.background = "black"
	end

	graphics.setBackgroundColor(world.current_area.background)

	world.current_level.modified = true
end

function editor.updateMusic()
	--TODO: This is dumb.
	if world.current_area.music == "overworld" then
		world.current_area.music = "underworld"
	elseif world.current_area.music == "underworld" then
		world.current_area.music = "boss"
	else
		world.current_area.music = "overworld"
	end

	game_resources.music.play(world.current_area.music)

	world.current_level.modified = true
end

function editor.resizeAreaToValidSize()
	local area = world.current_area

	if not area.valid_size then
		local msgbox_name = "Resizing area "..world.area.." to valid size"

		local msgbox_msg = "Are you sure you want to resize the area "..world.area.." to valid size?"..
		"\nNote that if you proceed any data outside of legal area will be irreversibly deleted."

		local msgbox_buttons = { "Proceed", "Cancel" }

		local button = love.window.showMessageBox(msgbox_name, msgbox_msg, msgbox_buttons, "warning")

		if button ~= 1 then
			return
		end

		print("Resizing area "..world.area)

		local previous_width = area.width
		local previous_height = area.height

		if not area.valid_width then
			if area.type == "horizontal" then
				area.width = 16

			elseif area.type == "vertical" then
				area.width = 256
			end

			print("\tPrevious width: "..previous_width.." -> new width: "..area.width)
		end

		if previous_width < area.width then

			for y = 0, (area.height / 16) - 1 do
				for x = (previous_width / 16), (area.width / 16) - 1 do
					area.tiles[y][x] = 0
				end
			end
		end

		if not area.valid_height then
			if area.type == "horizontal" then
				if area.height < 16 then
					area.height = 16
				else
					area.height = 240
				end
			elseif area.type == "vertical" then
				area.height = 16
			end

			print("\tPrevious height: "..previous_height.." -> new height: "..area.height)
		end

		area.valid_width = true
		area.valid_height = true
		area.valid_size = true

		editor.check.cursorBounds()
		editor.check.startingPositionBounds()

		editor.view.update()

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.shrinkAreaWidth()
	local area = world.current_area

	if area.width > 16 then
		area.width = area.width - 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)

		editor.check.cursorBounds()
		editor.check.startingPositionBounds()

		editor.check.viewBounds()

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.scratchAreaWidth()
	local area = world.current_area

	if area.width < 3744 then
		area.width = area.width + 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)

		editor.check.viewBounds()

		-- Clear newly added tile blocks
		local width = area.width / 16

		for i = 0, (area.height / 16) - 1 do
			area.tiles[i][width - 1] = 0
		end

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.shrinkAreaHeight()
	local area = world.current_area

	if area.height > 16 then
		area.height = area.height - 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)

		editor.check.cursorBounds()
		editor.check.startingPositionBounds()

		editor.check.viewBounds()

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.scratchAreaHeight()
	local area = world.current_area

	if area.height < 1440 then
		area.height = area.height + 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)

		editor.check.viewBounds()

		-- Clear newly added tile blocks
		local height = area.height / 16

		area.tiles[height - 1] = {}

		for i = 0, (area.width / 16) - 1 do
			area.tiles[height - 1][i] = 0
		end

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.changeTile(n)
	editor.tile = editor.tile + n

	if editor.tile < 0 then
		editor.tile = 0
	elseif editor.tile > 255 then
		editor.tile = 255
	end
end

function editor.placeTile(id)
	tile_x = editor.cursor_x / 16
	tile_y = editor.cursor_y / 16
	world.current_area.tiles[tile_y][tile_x] = id

	world.current_area.modified = true
end

function editor.removeTile()
	editor.placeTile(0)
end

return editor