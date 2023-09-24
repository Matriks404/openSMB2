local draw = {}

--TODO: Maybe there's a simpler way to do this...
function draw.menu()
	-- This is ridiculous, but it gets work done.
	local btn_3ds_up = graphics.images.btn_3ds_up
	local btn_3ds_down = graphics.images.btn_3ds_down
	local btn_3ds_left = graphics.images.btn_3ds_left
	local btn_3ds_right = graphics.images.btn_3ds_right
	local btn_3ds_a = graphics.images.btn_3ds_a
	local btn_3ds_b = graphics.images.btn_3ds_b
	local btn_3ds_x = graphics.images.btn_3ds_x
	local btn_3ds_y = graphics.images.btn_3ds_y
	local btn_3ds_l = graphics.images.btn_3ds_l
	local btn_3ds_r = graphics.images.btn_3ds_r

	graphics.drawText("        LEVEL EDITOR        ", 16, 8)
	graphics.drawText("      PRESS START AND       ", 16, 32)

	graphics.drawText("   - 1-1     - 1-2     - 1-3", 16, 48)
	love.graphics.draw(btn_3ds_up, 24, 48)
	love.graphics.draw(btn_3ds_down, 104, 48)
	love.graphics.draw(btn_3ds_left, 184, 48)

	graphics.drawText("   - 2-1     - 2-2     - 2-3", 16, 64)
	love.graphics.draw(btn_3ds_right, 24, 64)
	love.graphics.draw(btn_3ds_a, 104, 64)
	love.graphics.draw(btn_3ds_b, 184, 64)


	graphics.drawText("   - 3-1     - 3-2     - 3-3", 16, 80)
	love.graphics.draw(btn_3ds_x, 24, 80)
	love.graphics.draw(btn_3ds_y, 104, 80)
	love.graphics.draw(btn_3ds_l, 184, 80)

	graphics.drawText("   - 4-1                    ", 16, 96)
	love.graphics.draw(btn_3ds_r, 24, 96)

	graphics.drawText("      PRESS SELECT AND      ", 16, 128)
	graphics.drawText("             - 4-2     - 4-3", 16, 144)
	love.graphics.draw(btn_3ds_up, 104, 144)
	love.graphics.draw(btn_3ds_down, 184, 144)

	graphics.drawText("   - 5-1     - 5-2     - 5-3", 16, 160)
	love.graphics.draw(btn_3ds_left, 24, 160)
	love.graphics.draw(btn_3ds_right, 104, 160)
	love.graphics.draw(btn_3ds_a, 184, 160)

	graphics.drawText("   - 6-1     - 6-2     - 6-3", 16, 176)
	love.graphics.draw(btn_3ds_b, 24, 176)
	love.graphics.draw(btn_3ds_x, 104, 176)
	love.graphics.draw(btn_3ds_y, 184, 176)

	graphics.drawText("   - 7-1     - 7-2          ", 16, 192)
	love.graphics.draw(btn_3ds_l, 24, 192)
	love.graphics.draw(btn_3ds_r, 104, 192)

	graphics.drawText("      PRESS   TO EXIT       ", 16, 224)
	love.graphics.draw(btn_3ds_b, 112, 224)
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