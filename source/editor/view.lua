local view = {}

view.name = "normal" -- Editor view option (normal, detailed)

view.height = 0
view.width = 0

-- Editor view height offset (because topbar takes some space)
view.y_offset = 32

-- Editor view top-left coordinates
view.x = 0
view.y = 0

function view.reset()
	editor.cursor_x = 0
	editor.cursor_y = 0

	view.x = 0
	view.y = 0
end

function view.update()
	-- Calculate height and width of edit view
	view.height = world.current_area.height - view.y
	view.width = world.current_area.width - view.x

	if view.height > 208 then
		view.height = 208
	end

	if view.width > 256 then
		view.width = 256
	end
end

function view.alignCursorToView()
	if editor.cursor_x < view.x then
		editor.cursor_x = view.x

	elseif editor.cursor_x >= view.x + view.width then
		editor.cursor_x = view.x + view.width - 16
	end

	if editor.cursor_y < view.y then
		editor.cursor_y = view.y

	elseif editor.cursor_y >= view.y + view.height then
		editor.cursor_y = view.y + view.height - 16
	end
end

function view.alignToStartingPosition()
	local level = world.current_level

	local aligned_start_x = math.floor(level.start_x / 16) * 16
	local aligned_start_y = math.floor(level.start_y / 16) * 16

	if level.start_x < view.x then
		view.x = aligned_start_x

	elseif level.start_x >= view.x + view.width - 16 then
		view.x = aligned_start_x - view.width + 16
	end

	if level.start_y < view.y then
		view.y = aligned_start_y

	elseif level.start_y >= view.y + view.height - 16 then
		view.y = aligned_start_y - view.height + 16
	end
end

return view