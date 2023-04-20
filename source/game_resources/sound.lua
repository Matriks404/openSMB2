local sound = {}

function sound.load(directory)
	local directory = directory.."sound/"

	sound.loadSFX(directory)
	sound.loadMusic(directory)
end

function sound.loadSFX(directory)
	local directory = directory.."effects/"

	-- Optional
	sound.sfx_fall = resources.loadSound(directory.."fall.ogg", "static")
	sound.sfx_pickup = resources.loadSound(directory.."pickup.ogg", "static")
	sound.sfx_death = resources.loadSound(directory.."death.ogg", "static")
	sound.sfx_game_over = resources.loadSound(directory.."gameover.ogg", "static")
end

function sound.loadMusic(directory)
	local directory = directory.."music/"

	-- Optional

	music_title_file = directory.."title.ogg"
	music_char_select_file = directory.."charselect.ogg"
	music_overworld_file = directory.."overworld.ogg"
	music_underworld_file = directory.."underworld.ogg"
	music_boss_file = directory.."boss.ogg"

	sound.music_title = resources.loadSound(directory.."title.ogg", "stream")
	sound.music_char_select= resources.loadSound(directory.."charselect.ogg", "stream")
	sound.music_overworld = resources.loadSound(directory.."overworld.ogg", "stream")
	sound.music_underworld = resources.loadSound(directory.."underworld.ogg", "stream")
	sound.music_boss = resources.loadSound(directory.."boss.ogg", "stream")

	game_resources.music.m = {
		["title"] = { short_name = "TITL", track = sound.music_title },
		["character_select"] = { short_name = "CHA", track = sound.music_char_select },
		["overworld"] = { short_name = "OVR", track = sound.music_overworld },
		["underworld"] = { short_name = "UND", track = sound.music_underworld },
		["boss"] = { short_name = "BOS", track = sound.music_boss }
	}
end

return sound