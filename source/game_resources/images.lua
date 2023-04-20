local images = {}

function images.load(directory)
	local directory = directory.."images/"
	images.loadTitle(directory)
	images.loadCharacterSelect(directory)
	images.loadLevelbook(directory)
	images.loadGameplay(directory)

	-- Mandatory
	images.tilemap = resources.loadImage(directory.."tilemap.png", true)
	images.indicator = resources.loadImage(directory.."indicator.png", true)
end

function images.loadTitle(directory)
	local directory = directory.."title/"

	-- Recommended, but optional
	images.title_border = resources.loadImage(directory.."border.png", false)
	images.title_logo = resources.loadImage(directory.."logo.png", false)
end

function images.loadCharacterSelect(directory)
	local directory = directory.."charselect/"

	-- Recommended, but optional
	images.cs_border = resources.loadImage(directory.."border.png", false)

	images.cs_char1 = resources.loadImage(directory.."char1.png", false)
	images.cs_char2 = resources.loadImage(directory.."char2.png", false)
	images.cs_char3 = resources.loadImage(directory.."char3.png", false)
	images.cs_char4 = resources.loadImage(directory.."char4.png", false)

	images.cs_char1_active = resources.loadImage(directory.."char1_active.png", false)
	images.cs_char2_active = resources.loadImage(directory.."char2_active.png", false)
	images.cs_char3_active = resources.loadImage(directory.."char3_active.png", false)
	images.cs_char4_active = resources.loadImage(directory.."char4_active.png", false)

	images.cs_char1_select = resources.loadImage(directory.."char1_select.png", false)
	images.cs_char2_select = resources.loadImage(directory.."char2_select.png", false)
	images.cs_char3_select = resources.loadImage(directory.."char3_select.png", false)
	images.cs_char4_select = resources.loadImage(directory.."char4_select.png", false)

	-- Mandatory
	images.cs_arrow = resources.loadImage(directory.."arrow.png", true)
end

function images.loadLevelbook(directory)
	local directory = directory.."levelbook/"

	-- Optional
	images.levelbook = resources.loadImage(directory.."levelbook.png", false)
	images.lb_current = resources.loadImage(directory.."level_current.png", false)
	images.lb_other = resources.loadImage(directory.."level_other.png", false)
	images.lb_world1 = resources.loadImage(directory.."world1.png", false)
	images.lb_world2 = resources.loadImage(directory.."world2.png", false)
	images.lb_world4 = resources.loadImage(directory.."world4.png", false)
	images.lb_world7 = resources.loadImage(directory.."world7.png", false)
end

function images.loadCharacters(directory)
	local directory = directory.."characters/"

	-- Mandatory
	images.char1 = resources.loadImage(directory.."char1.png", true)
	images.char2 = resources.loadImage(directory.."char1.png", true)
	images.char3 = resources.loadImage(directory.."char1.png", true)
	images.char4 = resources.loadImage(directory.."char1.png", true)
end

function images.loadGameplay(directory)
	local directory = directory.."gameplay/"

	-- Recommended, but optional
	images.gp_filled = resources.loadImage(directory.."lifebar_filled.png", false)
	images.gp_empty = resources.loadImage(directory.."lifebar_empty.png", false)

	images.loadCharacters(directory)
end

return images