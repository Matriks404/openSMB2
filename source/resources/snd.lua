local snd = {}

function snd.load(directory)
	local directory = directory.."sound/"

	snd.loadSFX(directory)
	snd.loadMusic(directory)
end

function snd.loadSFX(directory)
	local directory = directory.."effects/"

	-- Optional

	sfx_fall_file = directory.."fall.ogg"
	sfx_pickup_file = directory.."pickup.ogg"
	sfx_death_file = directory.."death.ogg"
	sfx_game_over_file = directory.."gameover.ogg"

	if love.filesystem.getInfo(sfx_fall_file) then
		snd.sfx_fall= love.audio.newSource(sfx_fall_file, "static")
	end

	if love.filesystem.getInfo(sfx_pickup_file) then
		snd.sfx_pickup = love.audio.newSource(sfx_pickup_file, "static")
	end

	if love.filesystem.getInfo(sfx_death_file) then
		snd.sfx_death = love.audio.newSource(sfx_death_file, "static")
	end

	if love.filesystem.getInfo(sfx_game_over_file) then
		snd.sfx_game_over = love.audio.newSource(sfx_game_over_file, "static")
	end
end

function snd.loadMusic(directory)
	local directory = directory.."music/"

	-- Optional

	music_title_file = directory.."title.ogg"
	music_char_select_file = directory.."charselect.ogg"
	music_overworld_file = directory.."overworld.ogg"
	music_underworld_file = directory.."underworld.ogg"
	music_boss_file = directory.."boss.ogg"

	if love.filesystem.getInfo(music_title_file) then
		snd.music_title = love.audio.newSource(music_title_file, "stream")
	end

	if love.filesystem.getInfo(music_char_select_file) then
		snd.music_char_select = love.audio.newSource(music_char_select_file, "stream")
	end

	if love.filesystem.getInfo(music_overworld_file) then
		snd.music_overworld = love.audio.newSource(music_overworld_file, "stream")
	end

	if love.filesystem.getInfo(music_underworld_file) then
		snd.music_underworld = love.audio.newSource(music_underworld_file, "stream")
	end

	if love.filesystem.getInfo(music_boss_file) then
		snd.music_boss = love.audio.newSource(music_boss_file, "stream")
	end
end

return snd