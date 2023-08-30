local images = {}

function images.load(directory)
	local directory = directory.."images/"
	images.loadTitle(directory)
	images.loadCharacterSelect(directory)
	images.loadLevelbook(directory)
	images.loadGameplay(directory)

	-- Mandatory
	images.indicator = resources.loadImage(directory.."indicator.t3x", true)
	images.tilemap = resources.loadImage(directory.."tilemap.t3x", true)
end

function images.loadTitle(directory)
	local directory = directory.."title/"

	-- Recommended, but optional
	images.title_border = resources.loadImage(directory.."border.t3x", false)
	images.title_logo = resources.loadImage(directory.."logo.t3x", false)
end

function images.loadCharacterSelect(directory)
	local directory = directory.."charselect/"

	-- Recommended, but optional
	images.cs_border = resources.loadImage(directory.."border.t3x", false)

	images.cs_char1 = resources.loadImage(directory.."char1.t3x", false)
	images.cs_char2 = resources.loadImage(directory.."char2.t3x", false)
	images.cs_char3 = resources.loadImage(directory.."char3.t3x", false)
	images.cs_char4 = resources.loadImage(directory.."char4.t3x", false)

	images.cs_char1_active = resources.loadImage(directory.."char1_active.t3x", false)
	images.cs_char2_active = resources.loadImage(directory.."char2_active.t3x", false)
	images.cs_char3_active = resources.loadImage(directory.."char3_active.t3x", false)
	images.cs_char4_active = resources.loadImage(directory.."char4_active.t3x", false)

	images.cs_char1_select = resources.loadImage(directory.."char1_select.t3x", false)
	images.cs_char2_select = resources.loadImage(directory.."char2_select.t3x", false)
	images.cs_char3_select = resources.loadImage(directory.."char3_select.t3x", false)
	images.cs_char4_select = resources.loadImage(directory.."char4_select.t3x", false)

	-- Mandatory
	images.cs_arrow = resources.loadImage(directory.."arrow.t3x", true)
end

function images.loadLevelbook(directory)
	local directory = directory.."levelbook/"

	-- Optional
	images.levelbook = resources.loadImage(directory.."levelbook.t3x", false)
	images.lb_current = resources.loadImage(directory.."level_current.t3x", false)
	images.lb_other = resources.loadImage(directory.."level_other.t3x", false)
	images.lb_world1 = resources.loadImage(directory.."world1.t3x", false)
	images.lb_world2 = resources.loadImage(directory.."world2.t3x", false)
	images.lb_world4 = resources.loadImage(directory.."world4.t3x", false)
	images.lb_world7 = resources.loadImage(directory.."world7.t3x", false)
end

function images.loadCharacters(directory)
	local directory = directory.."characters/"

	-- Mandatory
	images.char1 = resources.loadImage(directory.."char1.t3x", true)
	images.char2 = resources.loadImage(directory.."char2.t3x", true)
	images.char3 = resources.loadImage(directory.."char3.t3x", true)
	images.char4 = resources.loadImage(directory.."char4.t3x", true)
end

function images.loadGameplay(directory)
	local directory = directory.."gameplay/"

	-- Recommended, but optional
	images.gp_filled = resources.loadImage(directory.."lifebar_filled.t3x", false)
	images.gp_empty = resources.loadImage(directory.."lifebar_empty.t3x", false)

	images.loadCharacters(directory)
end

return images