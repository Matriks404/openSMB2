local editor = {}

function editor.init()
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
end

return editor