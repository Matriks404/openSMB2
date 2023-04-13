local img = {}

function img.loadForGame(directory)
	local directory = directory.."images/"

	local title_dir = directory.."title/" -- Title screen and intro graphics
	local cs_dir = directory.."charselect/" -- Character select screen graphics
	local lb_dir = directory.."levelbook/" -- Levelbook screen graphics
	local gameplay_dir = directory.."gameplay/" -- Gameplay screen graphics
	local chars_dir = directory.."gameplay/characters/" -- Character graphics

	-- Title screen and intro graphics (optional)
	title_border_file = title_dir.."border.png"
	title_logo_file = title_dir.."logo.png"

	if love.filesystem.getInfo(title_border_file) then
		img.title_border = love.graphics.newImage(title_border_file)
	end

	if love.filesystem.getInfo(title_logo_file) then
		img.title_logo = love.graphics.newImage(title_logo_file)
	end

	-- Character select screen graphics (recommended)

	cs_border_file = cs_dir.."border.png"
	cs_char1_file = cs_dir.."char1.png"
	cs_char2_file = cs_dir.."char2.png"
	cs_char3_file = cs_dir.."char3.png"
	cs_char4_file = cs_dir.."char4.png"
	cs_char1_active_file = cs_dir.."char1_active.png"
	cs_char2_active_file = cs_dir.."char2_active.png"
	cs_char3_active_file = cs_dir.."char3_active.png"
	cs_char4_active_file = cs_dir.."char4_active.png"
	cs_char1_select_file = cs_dir.."char1_select.png"
	cs_char2_select_file = cs_dir.."char2_select.png"
	cs_char3_select_file = cs_dir.."char3_select.png"
	cs_char4_select_file = cs_dir.."char4_select.png"

	if love.filesystem.getInfo(cs_border_file) then
		img.cs_border = love.graphics.newImage(cs_border_file)
	end

	if love.filesystem.getInfo(cs_char1_file) then
		img.cs_char1 = love.graphics.newImage(cs_char1_file)
	end

	if love.filesystem.getInfo(cs_char2_file) then
		img.cs_char2 = love.graphics.newImage(cs_char2_file)
	end

	if love.filesystem.getInfo(cs_char3_file) then
		img.cs_char3 = love.graphics.newImage(cs_char3_file)
	end

	if love.filesystem.getInfo(cs_char4_file) then
		img.cs_char4 = love.graphics.newImage(cs_char4_file)
	end

	if love.filesystem.getInfo(cs_char1_active_file) then
		img.cs_char1_active = love.graphics.newImage(cs_char1_active_file)
	end

	if love.filesystem.getInfo(cs_char2_active_file) then
		img.cs_char2_active = love.graphics.newImage(cs_char2_active_file)
	end

	if love.filesystem.getInfo(cs_char3_active_file) then
		img.cs_char3_active = love.graphics.newImage(cs_char3_active_file)
	end

	if love.filesystem.getInfo(cs_char4_active_file) then
		img.cs_char4_active = love.graphics.newImage(cs_char4_active_file)
	end

	if love.filesystem.getInfo(cs_char1_select_file) then
		img.cs_char1_select = love.graphics.newImage(cs_char1_select_file)
	end

	if love.filesystem.getInfo(cs_char2_select_file) then
		img.cs_char2_select = love.graphics.newImage(cs_char2_select_file)
	end

	if love.filesystem.getInfo(cs_char3_select_file) then
		img.cs_char3_select = love.graphics.newImage(cs_char3_select_file)
	end

	if love.filesystem.getInfo(cs_char4_select_file) then
		img.cs_char4_select = love.graphics.newImage(cs_char4_select_file)
	end

	-- Character select screen graphics (mandatory)

	img.cs_arrow = love.graphics.newImage(cs_dir.."arrow.png")

	-- Levelbook screen graphics (optional)

	levelbook_file = lb_dir.."levelbook.png"
	lb_current_file = lb_dir.."level_current.png"
	lb_other_file = lb_dir.."level_other.png"
	lb_world1_file = lb_dir.."world1.png"
	lb_world2_file = lb_dir.."world2.png"
	lb_world4_file = lb_dir.."world4.png"
	lb_world7_file = lb_dir.."world7.png"

	if love.filesystem.getInfo(levelbook_file) then
		img.levelbook = love.graphics.newImage(levelbook_file)
	end

	if love.filesystem.getInfo(lb_current_file) then
		img.lb_current = love.graphics.newImage(lb_current_file)
	end

	if love.filesystem.getInfo(lb_other_file) then
		img.lb_other = love.graphics.newImage(lb_other_file)
	end

	if love.filesystem.getInfo(lb_world1_file) then
		img.lb_world1 = love.graphics.newImage(lb_world1_file)
	end

	if love.filesystem.getInfo(lb_world2_file) then
		img.lb_world2 = love.graphics.newImage(lb_world2_file)
	end

	if love.filesystem.getInfo(lb_world4_file) then
		img.lb_world4 = love.graphics.newImage(lb_world4_file)
	end

	if love.filesystem.getInfo(lb_world7_file) then
		img.lb_world7 = love.graphics.newImage(lb_world7_file)
	end

	-- Gameplay screen graphics (recommended)

	gp_filled_file = gameplay_dir.."lifebar_filled.png"
	gp_empty_file = gameplay_dir.."lifebar_empty.png"

	if love.filesystem.getInfo(gp_filled_file) then
		img.gp_filled = love.graphics.newImage(gp_filled_file)
	end

	if love.filesystem.getInfo(gp_empty_file) then
		img.gp_empty = love.graphics.newImage(gp_empty_file)
	end

	-- Character graphics (mandatory)
	img.char1 = love.graphics.newImage(chars_dir.."char1.png")
	img.char2 = love.graphics.newImage(chars_dir.."char2.png")
	img.char3 = love.graphics.newImage(chars_dir.."char3.png")
	img.char4 = love.graphics.newImage(chars_dir.."char4.png")

	-- Tilemap (mandatory)
	img.tilemap = love.graphics.newImage(directory.."tilemap.png")

	-- Selection indicator (mandatory)
	img.indicator = love.graphics.newImage(directory.."indicator.png")
end

function img.loadForEditor()
	local directory = "images/leveleditor/"

	img.editor_16x16_empty = love.graphics.newImage(editor_dir.."16x16.png")
	img.editor_16x16_cursor = love.graphics.newImage(editor_dir.."16x16_cursor.png")
	img.editor_sp = love.graphics.newImage(editor_dir.."starting_point.png")
	img.editor_sp_select = love.graphics.newImage(editor_dir.."starting_point_select.png")
	--img.editor_border_arrow = love.graphics.newImage(editor_dir.."border_arrow.png")
end

return img