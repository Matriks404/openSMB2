local init = {}

function init.loadResources()
	loadFonts()
	loadGraphics()
	loadMusic()
	loadSoundEffects()
	story.init()
end

function loadFonts()
	font_dir = "resources/images/font/" -- Fonts folder

	-- White and brown font graphics
	font_white = love.graphics.newImage(font_dir.."white.png")
	font_brown = love.graphics.newImage(font_dir.."brown.png")
end

function loadGraphics()
	-- Title screen and intro graphics
	img_title = "resources/images/title/"

	img_title_border = love.graphics.newImage(img_title.."border.png")
	img_title_logo = love.graphics.newImage(img_title.."logo.png")

	-- Character select screen graphics
	img_cs = "resources/images/charselect/"

	img_cs_border = love.graphics.newImage(img_cs.."border.png")

	img_cs_mario = love.graphics.newImage(img_cs.."mario.png")
	img_cs_luigi = love.graphics.newImage(img_cs.."luigi.png")
	img_cs_toad = love.graphics.newImage(img_cs.."toad.png")
	img_cs_peach = love.graphics.newImage(img_cs.."peach.png")

	img_cs_mario_active = love.graphics.newImage(img_cs.."mario_active.png")
	img_cs_luigi_active = love.graphics.newImage(img_cs.."luigi_active.png")
	img_cs_toad_active = love.graphics.newImage(img_cs.."toad_active.png")
	img_cs_peach_active = love.graphics.newImage(img_cs.."peach_active.png")

	img_cs_mario_select = love.graphics.newImage(img_cs.."mario_select.png")
	img_cs_luigi_select = love.graphics.newImage(img_cs.."luigi_select.png")
	img_cs_toad_select = love.graphics.newImage(img_cs.."toad_select.png")
	img_cs_peach_select = love.graphics.newImage(img_cs.."peach_select.png")

	img_cs_arrow = love.graphics.newImage(img_cs.."arrow.png")

	-- Levelbook screen graphics
	img_lb = "resources/images/levelbook/"

	img_levelbook = love.graphics.newImage(img_lb.."levelbook.png")
	img_lb_current = love.graphics.newImage(img_lb.."level_current.png")
	img_lb_other = love.graphics.newImage(img_lb.."level_other.png")

	img_lb_world1 = love.graphics.newImage(img_lb.."world1.png")
	img_lb_world2 = love.graphics.newImage(img_lb.."world2.png")
	img_lb_world4 = love.graphics.newImage(img_lb.."world4.png")
	img_lb_world7 = love.graphics.newImage(img_lb.."world7.png")

	-- Gameplay screen graphics
	img_gp = "resources/images/gameplay/"

	img_gp_filled = love.graphics.newImage(img_gp.."lifebar_filled.png")
	img_gp_empty = love.graphics.newImage(img_gp.."lifebar_empty.png")

	-- Level editor graphics
	img_editor = "resources/images/leveleditor/"

	img_editor_16x16_empty = love.graphics.newImage(img_editor.."16x16.png")
	img_editor_16x16_cursor = love.graphics.newImage(img_editor.."16x16_cursor.png")

	-- Tilemap graphics
	img_tilemap = love.graphics.newImage("resources/images/tilemap.png")

	-- Character graphics
	img_chars = "resources/images/gameplay/characters/"

	img_chars_mario = love.graphics.newImage(img_chars.."mario.png")
	img_chars_luigi = love.graphics.newImage(img_chars.."luigi.png")
	img_chars_toad = love.graphics.newImage(img_chars.."toad.png")
	img_chars_peach = love.graphics.newImage(img_chars.."peach.png")

	img_indicator = love.graphics.newImage("resources/images/indicator.png")
end

function loadMusic()
	music_dir = "resources/sound/music/" -- Music folder

	music_title = love.audio.newSource(music_dir.."title.ogg", "stream")
	music_char_select = love.audio.newSource(music_dir.."charselect.ogg", "stream")
	music_overworld = love.audio.newSource(music_dir.."overworld.ogg", "stream")
	music_underworld = love.audio.newSource(music_dir.."underworld.ogg", "stream")
	music_boss = love.audio.newSource(music_dir.."boss.ogg", "stream")
end

function loadSoundEffects()
	sfx_dir = "resources/sound/effects/" -- Sound effects folder

	sfx_fall = love.audio.newSource(sfx_dir.."fall.ogg", "static")
	sfx_cherry = love.audio.newSource(sfx_dir.."cherry.ogg", "static")
	sfx_death = love.audio.newSource(sfx_dir.."death.ogg", "static")
	sfx_game_over = love.audio.newSource(sfx_dir.."gameover.ogg", "static")
end

return init