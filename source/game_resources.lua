local game_resources = {}

game_resources.images = {}
game_resources.music = {}
game_resources.sound = {}

function game_resources.loadImagesList(directory)
	local directory = directory.."images/"

	local title_dir = directory.."title/"
	local cs_dir = directory.."charselect/"
	local levelbook_dir = directory.."levelbook/"
	local gameplay_dir = directory.."gameplay/"
	local characters_dir = directory.."gameplay/characters/"

	local list = {
		-- Common (mandatory)
		["indicator"] = { directory.."indicator.png", true },
		["tilemap"] = { directory.."tilemap.png", true },

		-- Title screen (recommended)
		["title_border"] = { title_dir.."border.png", false },
		["title_logo"] = { title_dir.."logo.png", false },

		-- Character select (recommended)
		["cs_border"] = { cs_dir.."border.png", false },
		["cs_char1"] = { cs_dir.."char1.png", false },
		["cs_char2"] = { cs_dir.."char2.png", false },
		["cs_char3"] = { cs_dir.."char3.png", false },
		["cs_char4"] = { cs_dir.."char4.png", false },
		["cs_char1_active"] = { cs_dir.."char1_active.png", false },
		["cs_char2_active"] = { cs_dir.."char2_active.png", false },
		["cs_char3_active"] = { cs_dir.."char3_active.png", false },
		["cs_char4_active"] = { cs_dir.."char4_active.png", false },
		["cs_char1_select"] = { cs_dir.."char1_select.png", false },
		["cs_char2_select"] = { cs_dir.."char2_select.png", false },
		["cs_char3_select"] = { cs_dir.."char3_select.png", false },
		["cs_char4_select"] = { cs_dir.."char4_select.png", false },

		-- Character select (mandatory)
		["cs_arrow"] = { cs_dir.."arrow.png", true },

		-- Levelbook (optional)
		["levelbook"] = { levelbook_dir.."levelbook.png", false },
		["lb_current"] = { levelbook_dir.."level_current.png", false },
		["lb_other"] = { levelbook_dir.."level_other.png", false },
		["lb_world1"] = { levelbook_dir.."world1.png", false },
		["lb_world2"] = { levelbook_dir.."world2.png", false },
		["lb_world4"] = { levelbook_dir.."world4.png", false },
		["lb_world7"] = { levelbook_dir.."world7.png", false },

		-- Gameplay (recommended)
		["gp_filled"] = { gameplay_dir.."lifebar_filled.png", false },
		["gp_empty"] = { gameplay_dir.."lifebar_empty.png", false },

		-- Gameplay characters (mandatory)
		["gp_char1"] = { characters_dir.."char1.png", true },
		["gp_char2"] = { characters_dir.."char2.png", true },
		["gp_char3"] = { characters_dir.."char3.png", true },
		["gp_char4"] = { characters_dir.."char4.png", true }
	}

	return list
end

function game_resources.loadMusicList(directory)
	local directory = directory.."sound/music/"

	-- These are optional.
	local list = {
		["title"] = { directory.."title.ogg", "TITL", false },
		["character_select"] = { directory.."charselect.ogg", "CHA", false },
		["overworld"] = { directory.."overworld.ogg", "OVR", false },
		["underworld"] = { directory.."underworld.ogg", "UND", false },
		["boss"] = { directory.."boss.ogg", "BOS", false },
	}

	return list
end

function game_resources.loadSoundEffectsList(directory)
	local directory = directory.."sound/effects/"

	-- These are optional.
	local list = {
		["fall"] = {directory.."fall.ogg", false },
		["pickup"] = {directory.."pickup.ogg", false },
		["death"] = {directory.."death.ogg", false },
		["game_over"] = {directory.."gameover.ogg", false }
	}

	return list
end

function game_resources.load(directory)
	local resource_dir = directory.."/resources/"

	font.load(resource_dir)

	local images_list = game_resources.loadImagesList(resource_dir)
	resources.loadImages(game_resources.images, images_list)

	local music_list = game_resources.loadMusicList(resource_dir)
	resources.loadMusic(game_resources.music, music_list)

	local sound_effects_list = game_resources.loadSoundEffectsList(resource_dir)
	resources.loadSoundEffects(game_resources.sound, sound_effects_list)

	game_resources.loadStory(resource_dir)
end

function game_resources.loadStory(directory)
	local path = directory.."story.lua"

	if not love.filesystem.getInfo(path) then
		print("Info: No 'story.lua' file.")

		return
	end

	local file = love.filesystem.read(path)
	local success, contents = pcall(TSerial.unpack, file)

	if not success then
		print("Warning: The 'story.lua' file is invalid! Title screen won't play intro story.")

		return
	end

	for i = 1, #contents do
		title.story[i] = contents[i]
	end
end

return game_resources