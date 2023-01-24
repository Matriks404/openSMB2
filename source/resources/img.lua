local img = {}

function img.load()
	local directory = "resources/images/"

	local title_dir = directory.."title/" -- Title screen and intro graphics
	local cs_dir = directory.."charselect/" -- Character select screen graphics
	local lb_dir = directory.."levelbook/" -- Levelbook screen graphics
	local gameplay_dir = directory.."gameplay/" -- Gameplay screen graphics
	local chars_dir = directory.."gameplay/characters/" -- Character graphics
	local editor_dir = directory.."leveleditor/" -- Level editor graphics

	-- Title screen and intro graphics
	do
		img.title_border = love.graphics.newImage(title_dir.."border.png")
		img.title_logo = love.graphics.newImage(title_dir.."logo.png")
	end

	-- Character select screen graphics
	do
		img.cs_border = love.graphics.newImage(cs_dir.."border.png")

		img.cs_mario = love.graphics.newImage(cs_dir.."mario.png")
		img.cs_luigi = love.graphics.newImage(cs_dir.."luigi.png")
		img.cs_toad = love.graphics.newImage(cs_dir.."toad.png")
		img.cs_peach = love.graphics.newImage(cs_dir.."peach.png")

		img.cs_mario_active = love.graphics.newImage(cs_dir.."mario_active.png")
		img.cs_luigi_active = love.graphics.newImage(cs_dir.."luigi_active.png")
		img.cs_toad_active = love.graphics.newImage(cs_dir.."toad_active.png")
		img.cs_peach_active = love.graphics.newImage(cs_dir.."peach_active.png")

		img.cs_mario_select = love.graphics.newImage(cs_dir.."mario_select.png")
		img.cs_luigi_select = love.graphics.newImage(cs_dir.."luigi_select.png")
		img.cs_toad_select = love.graphics.newImage(cs_dir.."toad_select.png")
		img.cs_peach_select = love.graphics.newImage(cs_dir.."peach_select.png")

		img.cs_arrow = love.graphics.newImage(cs_dir.."arrow.png")
	end

	-- Levelbook screen graphics
	do
		img.levelbook = love.graphics.newImage(lb_dir.."levelbook.png")
		img.lb_current = love.graphics.newImage(lb_dir.."level_current.png")
		img.lb_other = love.graphics.newImage(lb_dir.."level_other.png")

		img.lb_world1 = love.graphics.newImage(lb_dir.."world1.png")
		img.lb_world2 = love.graphics.newImage(lb_dir.."world2.png")
		img.lb_world4 = love.graphics.newImage(lb_dir.."world4.png")
		img.lb_world7 = love.graphics.newImage(lb_dir.."world7.png")
	end

	-- Gameplay screen graphics
	do
		img.gp_filled = love.graphics.newImage(gameplay_dir.."lifebar_filled.png")
		img.gp_empty = love.graphics.newImage(gameplay_dir.."lifebar_empty.png")
	end

	-- Character graphics
	do
		img.chars_mario = love.graphics.newImage(chars_dir.."mario.png")
		img.chars_luigi = love.graphics.newImage(chars_dir.."luigi.png")
		img.chars_toad = love.graphics.newImage(chars_dir.."toad.png")
		img.chars_peach = love.graphics.newImage(chars_dir.."peach.png")
	end

	-- Level editor graphics
	do
		img.editor_16x16_empty = love.graphics.newImage(editor_dir.."16x16.png")
		img.editor_16x16_cursor = love.graphics.newImage(editor_dir.."16x16_cursor.png")
		img.editor_sp = love.graphics.newImage(editor_dir.."starting_point.png")
		img.editor_sp_select = love.graphics.newImage(editor_dir.."starting_point_select.png")
	end

	-- Tilemap
	img.tilemap = love.graphics.newImage(directory.."tilemap.png")

	-- Selection indicator
	img.indicator = love.graphics.newImage(directory.."indicator.png")
end

return img