local state = {}

function state.init()
	-- Game state (title, intro, character_select, level_intro, gameplay, pause, death, game_over, editor, debug)
	game_state = "title"

	-- Timers
	timer = 0
	text_timer = 0
	transition_timer = 0
	backup_timer = 0
	dying_timer = 0
	hero_animation_timer = 0

	transition = false

	cursor = 0 -- Menu cursor

	-- Gameplay --TODO: Tidy this up
	character = "mario" -- Character (mario, luigi, toad, peach)
	continues = 2
	lifes = 3
	energy = 2
	energy_bars = 2
	hero_state = "falling" -- Hero state (falling, stationary)

	world = 1

	all_levels = 3
	level = 1

	all_areas = 1
	area = 0

	area_widths = {} -- Array of area widths
	area_heights = {} -- Array of area heights
	area_backgrounds = {} -- Array of backgrounds (0 - Black, 1 - Light blue)
	area_music = {} -- Array of music (0 - Overworld, 1 - Underworld)
	area_tiles = {} -- Array of area tiles

	screen_x = 0
	screen_y = 0

	-- Start coordinates
	hero_start_x = 0
	hero_start_y = 0

	hero_pos_x = 0
	hero_pos_y = 0

	-- Hero position subpixels
	hero_subpos_x = 0
	hero_subpos_y = 0 --TODO: Use it!

	hero_side = 1 -- On which side hero is looking at (-1 - Left, 1 - Right)
	hero_mov_dir = 1 -- In which direction hero is moving (-1 - Left, 1 - Right)
	hero_speed = 0
	hero_accel = 0 -- Hero acceleration

	editor.init()

	utils.setBackgroundColor("blue")
end

return state