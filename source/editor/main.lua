local editor = {}

editor.check = require "source/editor/check"
editor.draw = require "source/editor/draw"
editor.view = require "source/editor/view"

-- Level editor variables
editor.option = "select" -- Editor option (select, edit)
editor.tile = 1

editor.mode = "normal" -- Editor mode (normal, start)

editor.modes = {}
editor.modes["normal"] = { short_name = "N" }
editor.modes["start"] = { short_name = "S" }

-- Editor cursor coordinates
editor.cursor_x = 0
editor.cursor_y = 0

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
	end
end

function editor.loadLevel(world_no, level_no, area_no)
	world.load(world_no, world_no)

	world.update(world_no, level_no, area_no)
end

function editor.saveLevel(world_no, level_no)
	world.save(world.current, world.level)
end

function editor.playLevel()
	world.save(world.current, world.level)

	state.name = "character_select"
	world.area = 0

	window.resizable = false
	window.update()

	graphics.setBackgroundColor("black")
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
	if world.area > 0 then
		world.area = world.area - 1
	else
		world.area = world.current_level.area_count - 1
	end

	editor.goToArea(world.current, world.level, world.area)
end

function editor.goToNextArea()
	if world.area < world.current_level.area_count - 1 then
		world.area = world.area + 1
	else
		world.area = 0
	end

	editor.goToArea(world.current, world.level, world.area)
end

function editor.changeMode()
	if world.area == 0 and editor.mode == "normal" then
		editor.mode = "start"
	else
		editor.mode = "normal"

		editor.view.alignCursorToView()
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

	music.stopAll()
end

function editor.quitToDebugMenu()
	state.name = "debug"
	state.timer = 0

	graphics.setBackgroundColor("blue")
end

function editor.moveView(x, y)
	editor.view.y = editor.view.y + y
	editor.view.x = editor.view.x + x

	editor.check.levelBounds()
	editor.check.cursorViewBounds()
end

function editor.moveCursor(x, y)
	editor.cursor_x = editor.cursor_x + x
	editor.cursor_y = editor.cursor_y + y

	editor.check.cursorAreaBounds()
	editor.check.viewBounds()
end

function editor.moveStartingPosition(x, y)
	local level = world.current_level

	level.start_x = level.start_x + x
	level.start_y = level.start_y + y

	editor.check.startingPositionAreaBounds()
	editor.view.alignToStartingPosition()
end

function editor.updateType()
	--TODO: This is dumb.
	if world.current_area.type == "horizontal" then
		world.current_area.type = "vertical"
	else
		world.current_area.type = "horizontal"
	end

	world.checkAreaSizeValidity(world.current, world.level, world.area)

	world.current_area.modified = true
end

function editor.updateBackground()
	--TODO: This is dumb.
	if world.current_area.background == "black" then
		world.current_area.background = "light_blue"
	else
		world.current_area.background = "black"
	end

	graphics.setBackgroundColor(world.current_area.background)

	world.current_area.modified = true
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

	music.play(world.current_area.music)

	world.current_area.modified = true
end

function editor.shrinkAreaWidth()
	if world.current_area.width > 16 then
		world.current_area.width = world.current_area.width - 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)

		editor.check.cursorAreaBounds()
		editor.check.startingPositionAreaBounds()

		editor.check.viewBounds()

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.scratchAreaWidth()
	if world.current_area.width < 3744 then
		world.current_area.width = world.current_area.width + 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)

		editor.check.viewBounds()

		-- Clear newly added tile blocks
		local width = world.current_area.width / 16

		for i = 0, (world.current_area.height / 16) - 1 do
			world.current_area.tiles[i][width - 1] = 0
		end

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.shrinkAreaHeight()
	if world.current_area.height > 16 then
		world.current_area.height = world.current_area.height - 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)

		editor.check.cursorAreaBounds()
		editor.check.startingPositionAreaBounds()

		editor.check.viewBounds()

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.scratchAreaHeight()
	if world.current_area.height < 1440 then
		world.current_area.height = world.current_area.height + 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)

		editor.check.viewBounds()

		-- Clear newly added tile blocks
		local height = world.current_area.height / 16

		world.current_area.tiles[height - 1] = {}

		for i = 0, (world.current_area.width / 16) - 1 do
			world.current_area.tiles[height - 1][i] = 0
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

return editor