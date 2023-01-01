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

function editor.placeTile(tileid)
	editor.tile_x = editor.cursor_x / 16
	editor.tile_y = editor.cursor_y / 16
	world.current_area.tiles[editor.tile_y][editor.tile_x] = tileid
end

function editor.quit()
	editor.option = "select"

	editor.tile = 1

	editor.cursor_x = 0
	editor.cursor_y = 0

	editor.view_x = 0
	editor.view_y = 0

	graphics.setBackgroundColor("black")

	music.stop()
end

return editor