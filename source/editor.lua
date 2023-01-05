local editor = {}

-- Level editor variables
editor.option = "select" -- Editor option (select, edit)
editor.level_height = 0
editor.level_width = 0
editor.tile = 1

-- Editor cursor coordinates
editor.cursor_x = 0
editor.cursor_y = 0

-- Editor selected tile coordinates
editor.tile_x = 0
editor.tile_y = 0

-- Editor view coordinates
editor.view_x = 0
editor.view_y = 0

function editor.checkCursorBounds()
	if editor.cursor_x < 0 then
		editor.cursor_x = 0
	end

	if editor.cursor_y < 0 then
		editor.cursor_y = 0
	end

	if editor.cursor_x > world.current_area.width - 16 then
		editor.cursor_x = world.current_area.width - 16
	end

	if editor.cursor_y > world.current_area.height - 16 then
		editor.cursor_y = world.current_area.height - 16
	end
end

function editor.checkGridBounds()
	if editor.cursor_x < editor.view_x then
		editor.view_x = editor.view_x - 16

	elseif editor.cursor_x == editor.view_x + 256 then
		editor.view_x = editor.view_x + 16
	end

	if editor.cursor_y < editor.view_y then
		editor.view_y = editor.view_y - 16

	elseif editor.cursor_y == editor.view_y + 208 then
		editor.view_y = editor.view_y + 16
	end
end

function editor.openLevel()
	world.enter(world_no, level_no)

	if world[world_no][level_no] then
		window.resizable = true
		window.update()

		editor.option = "edit"
	end
end

function editor.moveCursor(x, y)
	editor.cursor_x = editor.cursor_x + x
	editor.cursor_y = editor.cursor_y + y

	editor.checkCursorBounds()
	editor.checkGridBounds()
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
	editor.tile_x = editor.cursor_x / 16
	editor.tile_y = editor.cursor_y / 16
	world.current_area.tiles[editor.tile_y][editor.tile_x] = id

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

	music.play()

	world.current_area.modified = true
end

function editor.shrinkAreaWidth()
	if world.current_area.width > 16 then
		world.current_area.width = world.current_area.width - 16

		editor.checkCursorBounds()
		editor.checkGridBounds()
	end

	world.current_level.modified = true
	world.current_area.modified = true
end

function editor.scratchAreaWidth()
	if world.current_area.width < 3744 then
		world.current_area.width = world.current_area.width + 16

		editor.checkCursorBounds()
		editor.checkGridBounds()

		for i = 0, (world.current_area.height / 16) - 1 do
		-- Clear newly added tile blocks
			width = world.current_area.width / 16
			world.current_area.tiles[i][width - 1] = 0
		end

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.shrinkAreaHeight()
	if world.current_area.height > 16 then
		world.current_area.height = world.current_area.height - 16

		editor.checkCursorBounds()
		editor.checkGridBounds()
	end

	world.current_level.modified = true
	world.current_area.modified = true
end

function editor.scratchAreaHeight()
	if world.current_area.height < 1440 then
		world.current_area.height = world.current_area.height + 16

		editor.checkCursorBounds()
		editor.checkGridBounds()

		-- Clear newly added tile blocks

		height = world.current_area.height / 16

		world.current_area.tiles[height - 1] = {}

		for j=0, (world.current_area.width / 16) - 1 do
			world.current_area.tiles[height - 1][j] = 0
		end
	end

	world.current_level.modified = true
	world.current_area.modified = true
end

function editor.goToArea(world_no, level_no, area_no)
	world.enter(world_no, level_no, area_no)

	editor.cursor_x = 0
	editor.cursor_y = 0

	editor.view_x = 0
	editor.view_y = 0
end

function editor.goToPreviousArea()
	if world.area > 0 then
		world.area = world.area - 1

	else
		world.area  = world.current_level.area_count - 1

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

function editor.loadLevel(world_no, level_no)
	world.unload(world_no, level_no)
	world.load(world_no, world_no)
end

function editor.playLevel()
	world.save(world.current, world.level)

	state.name = "character_select"
	world.area = 0
	frames = 0

	if debug.mute == false then
		music.stop()
		music_char_select:play()
	end

	graphics.setBackgroundColor("black")
end

function editor.quit()
	if world.current_level.modified then
		world.unload(world.current, world.level)
	end

	editor.option = "select"

	editor.tile = 1

	editor.cursor_x = 0
	editor.cursor_y = 0

	editor.view_x = 0
	editor.view_y = 0

	window.resizable = false
	window.update()

	graphics.setBackgroundColor("black")

	music.stop()
end

function editor.quitToDebugMenu()
	state.name = "debug"
	state.timer = 0

	graphics.setBackgroundColor("blue")
end

return editor