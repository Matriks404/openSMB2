local draw = {}

function draw.menu()
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

function draw.editor()
	local level = world.current_level
	local area = world.current_area

	local font1 = game_resources.font.primary
	local font2 = game_resources.font.secondary

	local font

	-- Draw world, level and area indicators
	graphics.drawText(world.current.."-"..world.level.."-"..world.area, 2, 2)

	-- Draw area type indicator
	font = (area.valid_size and font1) or font2
	graphics.drawText("TYPE-"..world.types[area.type].short_name, 58, 2, font)

	-- Draw editing mode indicator
	graphics.drawText("MODE-"..editor.modes[editor.mode].short_name, 138, 2)

	-- Draw background and music indicators
	graphics.drawText("B-"..graphics.bg[area.background].short_name, 2, 10)
	graphics.drawText("M-"..game_resources.music[area.music].short_name, 2, 18)

	-- Draw width and height values
	font = (area.valid_width and font1) or font2
	graphics.drawText("W-"..area.width, 58, 10, font)

	font = (area.valid_height and font1) or font2
	graphics.drawText("H-"..area.height, 58, 18, font)

	-- Draw coordinates for edit cursor or starting position
	local x, y

	if editor.mode == "normal" then
		x = editor.cursor_x
		y = editor.cursor_y

	elseif editor.mode == "start" then
		x = level.start_x
		y = level.start_y
	end

	graphics.drawText("X-"..x, 114, 10)
	graphics.drawText("Y-"..y, 114, 18)

	-- Draw currently selected tile
	local tile = string.upper(string.format("%x", editor.tile))
	graphics.drawText("TILE-"..tile, 178, 18)
	graphics.drawTile(editor.tile, 238, 12)

	draw.boxes()
	draw.tiles()
	draw.areaBorder()

	if editor.mode == "normal" then
		draw.cursor()
	end

	if world.area == 1 then
		draw.startingPosition()
	end
end

function draw.boxes()
	for i = 0, editor.view.height - 16, 16 do
		for j = 0, editor.view.width - 16, 16 do
			love.graphics.draw(editor.images["16x16_empty"], j, editor.view.y_offset + i)
		end
	end
end

function draw.tiles()
	local view_height_tiles = editor.view.height / graphics.tile_size
	local view_width_tiles = editor.view.width / graphics.tile_size

	local view_x_tiles = editor.view.x / graphics.tile_size
	local view_y_tiles = editor.view.y / graphics.tile_size
	local view_y_offset = editor.view.y_offset

	for i = 0, view_height_tiles - 1 do
		local tile_y = view_y_tiles + i
		local pos_y = view_y_offset + (i * graphics.tile_size)

		for j = 0, view_width_tiles - 1 do
			local tile_x = view_x_tiles + j
			local pos_x = j * graphics.tile_size

			local tile = world.current_area.tiles[tile_y][tile_x]

			graphics.drawTile(tile, pos_x, pos_y)

			if editor.view.name == "detailed" then
				tile_value = string.format("%X", tile)
				graphics.drawText(tile_value, pos_x, pos_y)
			end
		end
	end
end

function draw.areaBorderLine(x1, y1, x2, y2)
	love.graphics.setColor(0.75, 0, 0, 1)

	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(2)

	love.graphics.line(x1, y1, x2, y2)

	-- Restore original color
	love.graphics.setColor(1, 1, 1, 1)
end

function draw.areaBorder()
	local type = world.types[world.current_area.type]

	if type.horizontal_size then
		local x = type.horizontal_size - editor.view.x

		if x < 0 or x >= graphics.width then
			return
		end

		draw.areaBorderLine(x - 1, editor.view.y_offset, x - 1, graphics.height)
	end

	if type.vertical_max_size then
		local y = editor.view.y_offset + type.vertical_max_size - editor.view.y

		if y < editor.view.y_offset or y >= graphics.height then
			return
		end

		draw.areaBorderLine(0, y - 1, graphics.width, y - 1)
	end
end

function draw.cursor()
	love.graphics.draw(editor.images["16x16_cursor"], editor.cursor_x - editor.view.x, editor.cursor_y - editor.view.y + 32)
end

function draw.startingPosition()
	if editor.mode == "normal" then
		sp = editor.images["sp"]

	elseif editor.mode == "start" then
		sp = editor.images["sp_select"]
	end

	local x = world.current_level.start_x - editor.view.x
	local y = editor.view.y_offset + world.current_level.start_y - editor.view.y

	if x < 0 or x >= editor.view.width then
		return
	end

	if y < editor.view.y_offset or y >= editor.view.height + editor.view.y_offset then
		return
	end

	love.graphics.draw(sp, x, y)
end

return draw