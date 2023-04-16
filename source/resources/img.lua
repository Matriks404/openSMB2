local img = {}

function img.loadGameImages(directory)
	local directory = directory.."images/"

	img.loadTitleImages(directory)
	img.loadCharacterSelectImages(directory)
	img.loadLevelbookImages(directory)
	img.loadGameplayImages(directory)

	-- Mandatory
	img.tilemap = img.loadMandatoryImage(directory.."tilemap.png")
	img.indicator = img.loadMandatoryImage(directory.."indicator.png")
end

function img.loadEditorImages(directory)
	local directory = directory.."images/leveleditor/"

	img.editor_16x16_empty = love.graphics.newImage(directory.."16x16.png")
	img.editor_16x16_cursor = love.graphics.newImage(directory.."16x16_cursor.png")
	img.editor_sp = love.graphics.newImage(directory.."starting_point.png")
	img.editor_sp_select = love.graphics.newImage(directory.."starting_point_select.png")
	--img.editor_border_arrow = love.graphics.newImage(directory.."border_arrow.png")
end

function img.tryToLoadOptionalImage(file)
	local f = love.graphics.newImage

	return resources.tryToLoadOptionalFile(f, file)
end

function img.loadMandatoryImage(file)
	local f = love.graphics.newImage

	return resources.loadMandatoryFile(f, file)
end

function img.loadTitleImages(directory)
	local directory = directory.."title/"

	-- Recommended, but optional
	img.title_border = img.tryToLoadOptionalImage(directory.."border.png")
	img.title_logo = img.tryToLoadOptionalImage(directory.."logo.png")
end

function img.loadCharacterSelectImages(directory)
	local directory = directory.."charselect/"

	-- Recommended, but optional
	img.cs_border = img.tryToLoadOptionalImage(directory.."border.png")

	img.cs_char1 = img.tryToLoadOptionalImage(directory.."char1.png")
	img.cs_char2 = img.tryToLoadOptionalImage(directory.."char2.png")
	img.cs_char3 = img.tryToLoadOptionalImage(directory.."char3.png")
	img.cs_char4 = img.tryToLoadOptionalImage(directory.."char4.png")

	img.cs_char1_active = img.tryToLoadOptionalImage(directory.."char1_active.png")
	img.cs_char2_active = img.tryToLoadOptionalImage(directory.."char2_active.png")
	img.cs_char3_active = img.tryToLoadOptionalImage(directory.."char3_active.png")
	img.cs_char4_active = img.tryToLoadOptionalImage(directory.."char4_active.png")

	img.cs_char1_select = img.tryToLoadOptionalImage(directory.."char1_select.png")
	img.cs_char2_select = img.tryToLoadOptionalImage(directory.."char2_select.png")
	img.cs_char3_select = img.tryToLoadOptionalImage(directory.."char3_select.png")
	img.cs_char4_select = img.tryToLoadOptionalImage(directory.."char4_select.png")

	-- Mandatory
	img.cs_arrow = img.loadMandatoryImage(directory.."arrow.png")
end

function img.loadLevelbookImages(directory)
	local directory = directory.."levelbook/"

	-- Optional
	img.levelbook = img.tryToLoadOptionalImage(directory.."levelbook.png")
	img.lb_current = img.tryToLoadOptionalImage(directory.."level_current.png")
	img.lb_other = img.tryToLoadOptionalImage(directory.."level_other.png")
	img.lb_world1 = img.tryToLoadOptionalImage(directory.."world1.png")
	img.lb_world2 = img.tryToLoadOptionalImage(directory.."world2.png")
	img.lb_world4 = img.tryToLoadOptionalImage(directory.."world4.png")
	img.lb_world7 = img.tryToLoadOptionalImage(directory.."world7.png")
end

function img.loadCharacterImages(directory)
	local directory = directory.."characters/"

	img.char1 = img.loadMandatoryImage(directory.."char1.png")
	img.char2 = img.loadMandatoryImage(directory.."char1.png")
	img.char3 = img.loadMandatoryImage(directory.."char1.png")
	img.char4 = img.loadMandatoryImage(directory.."char1.png")
end

function img.loadGameplayImages(directory)
	local directory = directory.."gameplay/"

	-- Recommended, but optional
	img.gp_filled = img.tryToLoadOptionalImage(directory.."lifebar_filled.png")
	img.gp_empty = img.tryToLoadOptionalImage(directory.."lifebar_empty.png")

	img.loadCharacterImages(directory)
end

return img