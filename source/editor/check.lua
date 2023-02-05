local check = {}

function check.levelBounds()
	if editor.view.x < 0 then
		editor.view.x = 0

	elseif editor.view.x > world.current_area.width - editor.view.width then
		editor.view.x = world.current_area.width - editor.view.width
	end

	if editor.view.y < 0 then
		editor.view.y = 0

	elseif editor.view.y > world.current_area.height - editor.view.height then
		editor.view.y = world.current_area.height - editor.view.height
	end
end

function check.viewBounds()
	if editor.cursor_x < editor.view.x then
		editor.view.x = editor.view.x - 16

	elseif editor.cursor_x >= editor.view.x + 256 then
		editor.view.x = editor.view.x + 16
	end

	if editor.cursor_y < editor.view.y then
		editor.view.y = editor.view.y - 16

	elseif editor.cursor_y >= editor.view.y + 208 then
		editor.view.y = editor.view.y + 16
	end

	editor.view.update()
end

function check.cursorBounds()
	if editor.cursor_x < 0 then
		editor.cursor_x = 0

	elseif editor.cursor_x > world.current_area.width - 16 then
		editor.cursor_x = world.current_area.width - 16
	end

	if editor.cursor_y < 0 then
		editor.cursor_y = 0

	elseif editor.cursor_y > world.current_area.height - 16 then
		editor.cursor_y = world.current_area.height - 16
	end
end

function check.startingPositionBounds()
	if level.start_x < 0 then
		level.start_x = 0
	end

	if level.start_x >= level[0].width then
		level.start_x = level[0].width - 1
	end

	if level.start_y < 0 then
		level.start_y = 0
	end

	if level.start_y >= level[0].height then
		level.start_y = level[0].height - 1
	end
end

return check