local view = {}

view.name = "normal" -- Editor view option (normal, detailed)

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
	view.width = world.current_area.width - view.x
	view.height = world.current_area.height - view.y

	if view.width > 256 then
		view.width = 256
	end

	if view.height > 208 then
		view.height = 208
	end

	view.tiles_width = view.width / graphics.tile_size
	view.tiles_height = view.height / graphics.tile_size

	view.tile_x = view.x / graphics.tile_size
	view.tile_y = view.y / graphics.tile_size
end

function view.alignCursor()
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

function view.moveByTile(x, y)
	view.x = view.x + x
	view.y = view.y + y

	editor.check.levelBounds()
	view.alignCursor()

	view.update()
end

function view.moveByScreen(x, y)
	view.x = view.x + (x * view.width)
	view.y = view.y + (y * view.height)

	editor.check.levelBounds()
	view.alignCursor()

	view.update()
end

function view.moveTo(x, y)
	view.x = x
	view.y = y

	editor.check.levelBounds()

	view.update()
end

function view.moveToVerticalStart()
	view.moveTo(view.x, 0)

	editor.cursor_y = 0
end

function view.moveToHorizontalStart()
	view.moveTo(0, view.y)

	editor.cursor_x = 0
end

function view.moveToVerticalEnd()
	local x = view.x
	local y = world.current_area.height - view.height

	view.moveTo(x, y)

	editor.cursor_y = world.current_area.height - 16
end

function view.moveToHorizontalEnd()
	local x = world.current_area.width - view.width
	local y = view.y

	view.moveTo(x, y)

	editor.cursor_x = world.current_area.width - 16
end

return view