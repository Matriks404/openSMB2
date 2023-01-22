local editor = {}

-- Level editor variables
editor.option = "select" -- Editor option (select, edit)
editor.view = "normal" -- Editor view option (normal, detailed)
editor.tile = 1

-- Editor view height and width
editor.view_height = 0
editor.view_width = 0

-- Editor view height offset (because topbar takes some space)
editor.view_y_offset = 32

-- Editor view top-left coordinates
editor.view_x = 0
editor.view_y = 0

-- Editor cursor coordinates
editor.cursor_x = 0
editor.cursor_y = 0

function editor.resetView()
	editor.cursor_x = 0
	editor.cursor_y = 0

	editor.view_x = 0
	editor.view_y = 0
end

function editor.changeView()
	if editor.view == "normal" then
		editor.view = "detailed"
	else
		editor.view = "normal"
	end
end

function editor.updateView()
	-- Calculate height and width of edit view
	editor.view_height = world.current_area.height - editor.view_y
	editor.view_width = world.current_area.width - editor.view_x

	if editor.view_height > 208 then
		editor.view_height = 208
	end

	if editor.view_width > 256 then
		editor.view_width = 256
	end
end

function editor.checkCursorAreaBounds()
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

function editor.checkCursorViewBounds()
	if editor.cursor_x < editor.view_x then
		editor.cursor_x = editor.cursor_x + 16
	end

	if editor.cursor_x > editor.view_x + editor.view_width - 16 then
		editor.cursor_x = editor.cursor_x - 16
	end

	if editor.cursor_y < editor.view_y then
		editor.cursor_y = editor.cursor_y + 16
	end

	if editor.cursor_y > editor.view_y + editor.view_height - 16 then
		editor.cursor_y = editor.cursor_y - 16
	end

	editor.updateView()
end

function editor.checkViewBounds()
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

	editor.updateView()
end

function editor.checkLevelBounds()
	if editor.view_x < 0 then
		editor.view_x = 0
	end

	if editor.view_x > world.current_area.width - editor.view_width then
		editor.view_x = world.current_area.width - editor.view_width
	end

	if editor.view_y < 0 then
		editor.view_y = 0
	end

	if editor.view_y > world.current_area.height - editor.view_height then
		editor.view_y = world.current_area.height - editor.view_height
	end
end

function editor.openLevel()
	world.enter(world_no, level_no)

	if world[world_no][level_no] then
		window.resizable = true
		window.update()

		editor.option = "edit"
		editor.updateView()
	end
end

function editor.moveView(x, y)
	editor.view_y = editor.view_y + y
	editor.view_x = editor.view_x + x

	editor.checkLevelBounds()
	editor.checkCursorViewBounds()
end

function editor.moveCursor(x, y)
	editor.cursor_x = editor.cursor_x + x
	editor.cursor_y = editor.cursor_y + y

	editor.checkCursorAreaBounds()
	editor.checkViewBounds()
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
		editor.checkCursorAreaBounds()
		editor.checkViewBounds()

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.scratchAreaWidth()
	if world.current_area.width < 3744 then
		world.current_area.width = world.current_area.width + 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)
		editor.checkCursorAreaBounds()
		editor.checkViewBounds()

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
		editor.checkCursorAreaBounds()
		editor.checkViewBounds()

		world.current_level.modified = true
		world.current_area.modified = true
	end
end

function editor.scratchAreaHeight()
	if world.current_area.height < 1440 then
		world.current_area.height = world.current_area.height + 16

		world.checkAreaSizeValidity(world.current, world.level, world.area)
		editor.checkCursorAreaBounds()
		editor.checkViewBounds()

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

function editor.goToArea(world_no, level_no, area_no)
	world.enter(world_no, level_no, area_no)

	editor.resetView()
	editor.updateView()
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

function editor.loadLevel(world_no, level_no, area_no)
	world.load(world_no, world_no)

	world.update(world_no, level_no, area_no)
end

function editor.playLevel()
	world.save(world.current, world.level)

	state.name = "character_select"
	world.area = 0

	window.resizable = false
	window.update()

	graphics.setBackgroundColor("black")
end

function editor.quit()
	if world.isLevelModified(world.current, world.level) then
		world[world_no][level_no] = nil
	end

	editor.option = "select"
	editor.tile = 1

	editor.resetView()

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

function editor.draw()
	if editor.option == "select" then
		editor.drawSelectMenu()
	elseif editor.option == "edit" then
		editor.drawLevelEditor()
	end
end

function editor.drawSelectMenu()
	graphics.drawText("LEVEL EDITOR", 24, 32)

	graphics.drawText(" 1 - 1-1  4 - 2-1  7 - 3-1", 24, 64)
	graphics.drawText(" 2 - 1-2  5 - 2-2  8 - 3-2", 24, 80)
	graphics.drawText(" 3 - 1-3  6 - 2-3  9 - 3-3", 24, 96)

	graphics.drawText(" A - 4-1  D - 5-1  G - 6-1", 24, 128)
	graphics.drawText(" B - 4-2  E - 5-2  H - 6-2", 24, 144)
	graphics.drawText(" C - 4-3  F - 5-3  I - 6-3", 24, 160)

	graphics.drawText(" J - 7-1                  ", 24, 192)
	graphics.drawText(" K - 7-2          Q - QUIT", 24, 208)
end

function editor.drawBoxes()
	for i = 0, editor.view_height - 16, 16 do
		for j = 0, editor.view_width - 16, 16 do
			love.graphics.draw(img.editor_16x16_empty, j, editor.view_y_offset + i)
		end
	end
end

function editor.drawTiles()
	for i = 0, (editor.view_height / 16) - 1 do
		for j = 0, (editor.view_width / 16) - 1 do
			local tile_x = (editor.view_x / 16) + j
			local tile_y = (editor.view_y / 16) + i

			local pos_x = j * 16
			local pos_y = editor.view_y_offset + (i * 16)

			local tile = world.current_area.tiles[tile_y][tile_x]

			graphics.drawTile(tile, pos_x, pos_y)

			if editor.view == "detailed" then
				tile = string.upper(string.format("%x", tile))

				graphics.drawText(tile, pos_x, pos_y)
			end
		end
	end
end

function editor.drawStartingPosition()
	local x = world.current_level.start_x - editor.view_x
	local y = editor.view_y_offset + world.current_level.start_y - editor.view_y

	if x < 0 or x >= editor.view_width then
		return
	end

	if y < editor.view_y_offset or y >= editor.view_height + editor.view_y_offset then
		return
	end

	love.graphics.draw(img.editor_sp, x, y)
end

function editor.drawCursor()
	love.graphics.draw(img.editor_16x16_cursor, editor.cursor_x - editor.view_x, editor.cursor_y - editor.view_y + 32)
end


function editor.drawLevelEditor()
	local area = world.current_area
	local font

	-- Draw world, level and area indicators
	graphics.drawText(world.current.."-"..world.level.."-"..world.area, 2, 2)

	-- Draw area type indicator
	font = (area.valid_size and "white") or "brown"
	graphics.drawText("T-"..world.types[area.type].short_name, 50, 2, font)

	-- Draw background and music indicators
	graphics.drawText("B-"..graphics.bg[area.background].short_name, 90, 2)
	graphics.drawText("M-"..music.m[area.music].short_name, 146, 2)

	-- Draw width and height values
	font = (area.valid_width and "white") or "brown"
	graphics.drawText("W-"..area.width, 2, 10, font)

	font = (area.valid_height and "white") or "brown"
	graphics.drawText("H-"..area.height, 2, 18, font)

	-- Draw coordinates for edit cursor
	graphics.drawText("X-"..editor.cursor_x, 66, 10)
	graphics.drawText("Y-"..editor.cursor_y, 66, 18)

	-- Draw currently selected tile
	local tile = string.upper(string.format("%x", editor.tile))
	graphics.drawText("TILE-"..tile, 178, 18)
	graphics.drawTile(editor.tile, 238, 12)

	editor.drawBoxes()
	editor.drawTiles()

	editor.drawCursor()

	if world.area == 0 then
		editor.drawStartingPosition()
	end
end

return editor