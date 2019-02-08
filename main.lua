debug = require "source/debug"
editor = require "source/editor"
init = require "source/init"
state = require "source/state"
story = require "source/story"
utils = require "source/utils"

function love.load()
	GAME_TITLE = "openSMB2"
	GAME_FULL_TITLE = GAME_TITLE.." v"..utils.getVersion()

	-- Game window size (NES resolution)
	GAME_WIDTH = 256
	GAME_HEIGHT = 240

	-- Setting up window
	love.window.setMode(GAME_WIDTH, GAME_HEIGHT, {vsync = true})
	love.window.setTitle(GAME_FULL_TITLE)
	love.filesystem.setIdentity(GAME_TITLE)

	init.loadResources()

	state.init()
	debug.reset()
end

function love.update()
	timer = timer + 1

	if game_state == "title" then
	-- Title screen stuff
		music_title:play()

		-- After some time go to intro story
		if timer == 500 then
			game_state = "intro"
			timer = 0
		end

	elseif game_state == "intro" then
	-- Intro story stuff
		if transition == true then
			transition_timer = transition_timer + 1

			-- After some time after showing 2nd story page go to title screen again
			if transition_timer == 442 then
				game_state = "title"
				timer = 0
				text_timer = 0

				story.lines = 0
				story.page = 0

				transitionClear()
			end
		end

	elseif game_state == "character_select" then
	-- Character select stuff
		if transition == true then
			transition_timer = transition_timer + 1

			-- After some time after chosing character go to levelbook screen
			if transition_timer == 136 then
				game_state = "level_intro"
				timer = 0

				music_char_select:stop()
				transitionClear()

				-- Chosen character is one that was selected previously by cursor
				if cursor == 0 then     character = "mario"
				elseif cursor == 1 then character = "luigi"
				elseif cursor == 2 then character = "toad"
				elseif cursor == 3 then character = "peach"
				end
			end
		end

	elseif game_state == "level_intro" then
	-- Levelbook stuff
		if timer == 94 then
			game_state = "gameplay"
			timer = 0

			loadLevel()

			screen_y = 0 --TEMPORARY
			hero_pos_x = hero_start_x
			hero_pos_y = hero_start_y

			hero_animation_timer = 0
		end

	elseif game_state == "gameplay" then
	-- Gameplay stuff
		if screen_y == 0 and hero_pos_y > 192 then
		-- When on first screen, switching vertical screen downwards
			screendir = 1
			screenTrans()

		elseif screen_y > 0 then
		-- When on subsequent screen
			if hero_pos_y > 192 + screen_y * 144 then
			-- Switching vertical screen downwards
				if hero_pos_y <= area_heights[area] - 48 then
				-- If not above lowest screen border switch screen
					screendir = 1
					screenTrans()
				elseif hero_pos_y >= area_heights[area] - 1 then
				-- Die!
					dying_timer = dying_timer + 1
				end

			elseif hero_pos_y < 16 + screen_y * 144 then
			-- Switching vertical screen upwords
				screendir = -1
				screenTrans()
			end
		end

		if timer > 146 and transition_timer == 0 then

			if debug.mode == true and love.keyboard.isDown("a") then
			-- Ascending
				hero_pos_y = hero_pos_y - 3.25
			end

			-- Left/Right movement
			if love.keyboard.isDown("left") then
				hero_side = -1

				if hero_speed == 0 then
					hero_mov_dir = -1
				end

				if hero_mov_dir == 1 then
					hero_speed = hero_speed - 4
					hero_accel = hero_accel - 1
				else
					if hero_accel < 6 then
						hero_accel = hero_accel + 1
					end

					if love.keyboard.isDown("z") then
						hero_speed = 6 * hero_accel
					else
						hero_speed = 4 * hero_accel
					end
				end

			elseif love.keyboard.isDown("right") then
				hero_side = 1

				if hero_speed == 0 then
					hero_mov_dir = 1
				end

				if hero_mov_dir == -1 then
					hero_speed = hero_speed - 4
					hero_accel = hero_accel - 1
				else
					if hero_accel < 6 then
						hero_accel = hero_accel + 1
					end

					if love.keyboard.isDown("z") then
						hero_speed = 6 * hero_accel
					else
						hero_speed = 4 * hero_accel
					end
				end

			elseif hero_speed > 0 then
			-- Reduce speed after time
				hero_speed = hero_speed - 4
				hero_accel = hero_accel - 1
			end

			if hero_accel < 0 then
			-- Reseting hero acceleration to 0
				hero_accel = 0
			end

			if hero_speed > 0 then
				-- Calculating character position
				hero_subpos_x = hero_subpos_x + hero_speed * hero_mov_dir

				while hero_subpos_x >= 16 or hero_subpos_x <= -16 do
					hero_subpos_x = hero_subpos_x - 16 * hero_mov_dir
					hero_pos_x = hero_pos_x + hero_mov_dir
				end

				-- Horizontal character position wraping
				if hero_pos_x > area_widths[area] then
					hero_pos_x = 0 + hero_pos_x % area_widths[area]

				elseif hero_pos_x < 0 then
					hero_pos_x = area_widths[area] + hero_pos_x
				end

			elseif hero_speed < 0 then
			-- Reset hero speed to 0
				hero_speed = 0
			end

			-- Character falling (slower for Luigi) --TEMPORARY
			if character == "luigi" then
				hero_pos_y = hero_pos_y + 2.5
			else
				hero_pos_y = hero_pos_y + 3
			end

			if dying_timer == 6 then
			-- Deplate energy and play death sound
				energy = 0

				stopAreaMusic()
				sfx_death:play()
			end

			if dying_timer == 84 then
			-- Die!
				timer = 0
				dying_timer = 0

				lifes = lifes - 1 -- Decrement a life

				if lifes > 0 then
				-- Going to death screen and playing once more
					energy = 2 -- Reset energy

					-- Reset character position and side
					screen_y = 0 --TEMPORARY
					hero_pos_x = hero_start_x
					hero_pos_y = hero_start_y
					hero_side = 1

					game_state = "death"
				else
				-- No more lifes, go to game over screen
					sfx_game_over:play()

					if continues > 0 then
						cursor = 0
					else
						cursor = 1
					end

					game_state = "game_over"
				end
			end

			--TODO: More physics!
		end
	end
end

function love.keyreleased(key)
	-- Quit if user pressed ESC key
	if key == "escape" then
		love.event.quit()
	end

	-- Title screen, intro story or debug screen
	if game_state == "title" or game_state == "intro" or game_state == "debug" then
		if key == "s" then
		-- Go to character screen
			game_state = "character_select"
			timer = 0

			music_title:stop()
			transitionClear()

			if debug.mute == false then
				music_char_select:play()
			end

			-- Set up gameplay variables just after leaving title screen, as player will return to character select screen every completion of level.
			world = 1
			level = 1

			continues = 2
			lifes = 3
			energy = 2
			energy_bars = 2
			hero_state = "falling"

			utils.setBackgroundColor("black")

		elseif love.keyboard.isDown("lctrl") and key == "d" then
		-- Go to debug screen or title screen (depending on origin screen)
			if debug.mode == false then
				game_state = "debug"
				timer = 0

				debug.mode = true

				music_title:stop()
			else
				game_state = "title"
				timer = 0

				debug.mode = false
				debug.mute = false
			end
		end
	end

	if game_state == "character_select" then
	-- Character select screen
		if key == "left" and transition_timer == 0 then
		-- Select character on the left
			if cursor > 0 then
				cursor = cursor - 1
			else
				cursor = 3
			end

			sfx_cherry:play()

		elseif key == "right" and transition_timer == 0 then
		-- Select character on the right
			if cursor < 3 then
				cursor = cursor + 1
			else
				cursor = 0
			end

			sfx_cherry:play()

		elseif key == "x" and transition_timer == 0 then
		-- Choose character and enable transition which will go to levelbook after some time
			transition = true

			sfx_cherry:play()
		end

	elseif game_state == "gameplay" then
	-- Gameplay screen
		if key == "s" and timer > 146 and transition_timer == 0 then
		-- Go to pause screen
			game_state = "pause"

			backup_timer = timer
			timer = 0
		end

		if debug.mode == true then
			if key == "d" then
			-- Die!
				dying_timer = 84

				stopAreaMusic()
			end
		end

	elseif game_state == "pause" then
	-- Pause screen
		if key == "s" then
		-- Go back to gameplay
			game_state = "gameplay"

			timer = backup_timer -- Backup gameplay timer
			transition_timer = 0
		end

	elseif game_state == "game_over" then
	-- Game over screen
		if key == "a" and continues > 0 then
		-- Select option
			if cursor == 0 then
				cursor = 1
			else
				cursor = 0
			end
		end

		if key == "s" then
			if cursor == 0 then
				continues = continues - 1
				lifes = 3
				energy = 2

				music_char_select:play()

				game_state = "character_select"
			else
				utils.setBackgroundColor("blue")

				cursor = 0
				timer = 0
				game_state = "title"
			end
		end

	elseif game_state == "editor" then
	-- Level editor screen
		if editor.option == "select" then
		-- Level select
			-- Set world according to world table
			if key >= "1" and key <= "3" then                  world = 1
			elseif key >= "4" and key <= "6" then              world = 2
			elseif key >= "7" and key <= "9" then              world = 3
			elseif key == "a" or key == "b" or key == "c" then world = 4
			elseif key == "d" or key == "e" or key == "f" then world = 5
			elseif key == "g" or key == "h" or key == "i" then world = 6
			elseif key == "j" or key == "k" then               world = 7
			end

			-- Go to proper editor
			if key >= "1" and key <= "9" then
				editor.option = "edit"
				level = ((key - 1) % 3) + 1
				area = 0

				loadLevel()

			elseif string.byte(key) >= string.byte("a") and string.byte(key) <= string.byte("k") then
				editor.option = "edit"
				level = ((string.byte(key) - 97) % 3) + 1
				area = 0

				loadLevel()

			elseif key == "q" then
			-- Quit menu to debug screen
				game_state = "debug"
				timer = 0

				utils.setBackgroundColor("blue")
			end

		elseif editor.option == "edit" then
		-- Edit map option
			if key == "b" then
			-- Change background color
				if area_backgrounds[area] == 0 then
					area_backgrounds[area] = 1

					utils.setBackgroundColor("light_blue")
				else
					area_backgrounds[area] = 0

					utils.setBackgroundColor("black")
				end

			elseif key == "m" then
			-- Change music
				if area_music[area] < 2 then
					area_music[area] = area_music[area] + 1

					playAreaMusic()
				else
					area_music[area] = 0

					playAreaMusic()
				end

			-- Shrink or scratch width/height
			elseif key == "kp4" then
				if area_widths[area] > 16 then
					area_widths[area] = area_widths[area] - 16

					checkEditCursorBounds()
					checkEditGridBounds()
				end

			elseif key == "kp6" then
				if area_widths[area] < 3744 then
					area_widths[area] = area_widths[area] + 16

					checkEditCursorBounds()
					checkEditGridBounds()

					for i=0, (area_heights[area] / 16) - 1 do
					-- Clear newly added tile blocks
						area_tiles[i][(area_widths[area] / 16) - 1] = 0
					end
				end

			elseif key == "kp8" then
				if area_heights[area] > 16 then
					area_heights[area] = area_heights[area] - 16

					checkEditCursorBounds()
					checkEditGridBounds()
				end

			elseif key == "kp2" then
				if area_heights[area] < 1440 then
					area_heights[area] = area_heights[area] + 16

					checkEditCursorBounds()
					checkEditGridBounds()

					-- Clear newly added tile blocks
					area_tiles[(area_heights[area] / 16) - 1] = {}

					for j=0, (area_widths[area] / 16) - 1 do
						area_tiles[(area_heights[area] / 16) - 1][j] = 0
					end
				end

			-- Change current areas
			elseif key == "[" then
				saveLevel()

				if area > 0 then
					area = area - 1

				else
					area  = all_areas - 1

				end

				loadArea()

				editor.cursor_x = 0
				editor.cursor_y = 0

				editor.view_x = 0
				editor.view_y = 0

			elseif key == "]" then
				saveLevel()

				if area < all_areas - 1 then
					area = area + 1

				else
					area = 0

				end

				loadArea()

				editor.cursor_x = 0
				editor.cursor_y = 0

				editor.view_x = 0
				editor.view_y = 0

			-- Move edit cursor
			elseif key == "left" and editor.cursor_x > 0 then
				editor.cursor_x = editor.cursor_x - 16

				checkEditGridBounds()

			elseif key == "right" and editor.cursor_x < area_widths[area] - 16 then
				editor.cursor_x = editor.cursor_x + 16

				checkEditGridBounds()

			elseif key == "up" and editor.cursor_y > 0 then
				editor.cursor_y = editor.cursor_y - 16

				checkEditGridBounds()

			elseif key == "down" and editor.cursor_y < area_heights[area] - 16 then
				editor.cursor_y = editor.cursor_y + 16

				checkEditGridBounds()

			-- Change selected tile
			elseif key == "w" and editor.tile > 15 then
				editor.tile = editor.tile - 16

			elseif key == "s" and editor.tile < 240 then
				editor.tile = editor.tile + 16

			elseif key == "a" and editor.tile > 0 then
				editor.tile = editor.tile - 1

			elseif key == "d" and editor.tile < 255 then
				editor.tile = editor.tile + 1

			elseif key == "z" then
			-- Remove tile
				placeTile(0)

			elseif key == "x" then
			-- Place tile
				placeTile(editor.tile)

			elseif key == "l" then
			-- Load this level from file
				loadLevel()

			elseif key == "v" then
			-- Save this level to file
				saveLevel()

			elseif key == "p" then
			-- Play from this level (doesn't return to level editor)
				saveLevel()

				game_state = "gameplay"
				area = 0
				frames = 0

				if debug.mute == false then
					stopAreaMusic()
					music_char_select:play()
				end

				utils.setBackgroundColor("black")


			elseif key == "q" then
			-- Quit to editor menu
				quitEditor()

			elseif key == "e" then
			-- Quit to editor menu and save level
				saveLevel()
				quitEditor()
			end
		end

	elseif game_state == "debug" then
	-- Debug screen
		if key == "f" then
		-- Show FPS counter or not
			if debug.fps == false then
				debug.fps = true
			else
				debug.fps = false
			end

		elseif key == "r" then
		-- Show frames counter or not
			if debug.frames == false then
				debug.frames = true
			else
				debug.frames = false
			end

		-- Mute music or not
		elseif key == "m" then
			if debug.mute == false then
				debug.mute = true
			else
				debug.mute = false
			end

		elseif key == "l" then
		-- Go to level editor
			game_state = "editor"
			timer = 0

			debug.frames = false
			editor.option = "select"

			utils.setBackgroundColor("black")
		end
	end
end

function love.draw()
	if game_state == "title" or game_state == "intro" or game_state == "debug" then
	-- Draw border on title screen and intro
		love.graphics.draw(img_title_border, 0, 0)
	end

	if game_state == "title" then
	-- Draw title screen stuff
		love.graphics.draw(img_title_logo, 48, 48)

		drawText("!\"", 193, 72)
		drawText("#1988 NINTENDO", 72, 184)

	elseif game_state == "intro" then
	-- Draw intro story stuff
		if timer > 34 then
			drawText("STORY", 112, 40)

			if text_timer > 65 then
			-- Based on timer add new line of text
				story.lines = story.lines + 1
				text_timer = 0

				if story.page == 0 and story.lines > 8 then
				-- Change to 2nd story page if all lines are displayed
					story.lines = 0
					story.page = 1
					text_timer = 50

				elseif story.page == 1 and story.lines > 8 then
				-- Enable transition which will go to title screen after some time
					story.lines = 8
					transition = true
				end
			end

			text_timer = text_timer + 1

			for i=0, story.lines do
			-- Draw lines of text
				if story.page == 0 then
					drawText(tostring(story.page1[i]), 48, 64 + ((i - 1) * 16))
				else
					drawText(tostring(story.page2[i]), 48, 64 + ((i - 1) * 16))
				end
			end
		end

	elseif game_state == "character_select" then
	-- Draw character select screen stuff
		love.graphics.draw(img_cs_border, 0, 0)

		drawText("PLEASE SELECT", 72, 80)
		drawText("PLAYER", 96, 96)

		love.graphics.draw(img_cs_arrow, 72 + (cursor * 32), 112)

		if cursor == 0 then
		-- Draw Mario
			if transition_timer < 3 or transition_timer > 68 then
				love.graphics.draw(img_cs_mario_active, 72, 144)
			else
				love.graphics.draw(img_cs_mario_select, 72, 144)
			end
		else
			love.graphics.draw(img_cs_mario, 72, 144)
		end

		if cursor == 1 then
		-- Draw Luigi
			if transition_timer < 3 or transition_timer > 68 then
				love.graphics.draw(img_cs_luigi_active, 104, 144)
			else
				love.graphics.draw(img_cs_luigi_select, 104, 144)
			end
		else
			love.graphics.draw(img_cs_luigi, 104, 144)
		end

		if cursor == 2 then
		-- Draw Toad
			if transition_timer < 3 or transition_timer > 68 then
				love.graphics.draw(img_cs_toad_active, 136, 144)
			else
				love.graphics.draw(img_cs_toad_select, 136, 144)
			end
		else
			love.graphics.draw(img_cs_toad, 136, 144)
		end

		if cursor == 3 then
		-- Draw Peach
			if transition_timer < 3 or transition_timer > 68 then
				love.graphics.draw(img_cs_peach_active, 168, 144)
			else
				love.graphics.draw(img_cs_peach_select, 168, 144)
			end
		else
			love.graphics.draw(img_cs_peach, 168, 144)
		end

		drawText("EXTRA LIFE", 64, 208)
		drawText(remainingLifes(), 176, 208)

	elseif game_state == "level_intro" then
		drawLevelbook() -- Draw levelbook

		drawWorldImage() -- Draw world image

	elseif game_state == "gameplay" then
	-- Draw gameplay stuff

		if timer > 144 then drawLevelTiles() -- Draw level tiles
		end

		if timer > 146 then
		-- Draw everything else
			if timer == 147 then
				sfx_fall:play() -- Play falling sound
			end

			for i=0, energy_bars - 1 do
			-- Draw energy bars
				if i+1 <= energy then
					love.graphics.draw(img_gp_filled, 12, 48 + (i * 16))
				else
					love.graphics.draw(img_gp_empty, 12, 48 + (i * 16))
				end
			end

			drawCharacter() -- Draw character on screen

			--TODO: Draw entities
		end

	elseif game_state == "pause" then
	-- Draw pause screen stuff
		drawLevelbook() -- Draw levelbook

		-- Draw flickering pause text
		if transition_timer == 30 then
			transition_timer = 0

		elseif transition_timer >= 15 then
			drawText("PAUSED", 105, 120, "brown")
		end

		drawText("EXTRA LIFE*** "..remainingLifes(), 65, 176, "brown") -- Draw extra lifes text

		transition_timer = transition_timer + 1

	elseif game_state == "death" then
	-- Draw dying screen stuff

		drawLevelbook() -- Draw levelbook

		drawText("EXTRA LIFE*** "..remainingLifes(), 65, 80, "brown") -- Draw remaining lifes

		drawWorldImage() -- Draw world image

		if timer >= 120 then
		-- Go to gameplay once again!
			game_state = "gameplay"
			timer = 0

			playAreaMusic()
		end

	elseif game_state == "game_over" then
	-- Draw game over screen stuff
		if timer < 192 then
			drawText("GAME  OVER", 88, 112)
		else
			-- Draw text
			if continues > 0 then
				drawText("CONTINUE "..tostring(continues), 96, 88)
			end

			drawText("RETRY", 96, 104)

			love.graphics.draw(img_indicator, 81, 89 + cursor * 16)
		end

	elseif game_state == "editor" then
	-- Draw level editor stuff
		if editor.option == "select" then
		-- Draw level editor menu
			drawText(string.upper(GAME_FULL_TITLE), 32, 32)
			drawText("LEVEL EDITOR", 32, 48)

			drawText("LEVEL SELECT", 32, 80)

			drawText(" 1 - 1-1  4 - 2-1  7 - 3-1", 32, 96)
			drawText(" 2 - 1-2  5 - 2-2  8 - 3-2", 32, 112)
			drawText(" 3 - 1-3  6 - 2-3  9 - 3-3", 32, 128)

			drawText(" A - 4-1  D - 5-1  G - 6-1", 32, 160)
			drawText(" B - 4-2  E - 5-2  H - 6-2", 32, 176)
			drawText(" C - 4-3  F - 5-3  I - 6-3", 32, 192)

			drawText(" J - 7-1  K - 7-2  Q - QUIT", 32, 224)

		elseif editor.option == "edit" then
		-- Draw editor
			-- Draw world, level and area indicators
			drawText(tostring(world).."-"..tostring(level), 64, 2)
			drawText("A-"..tostring(area), 104, 2)

			-- Draw background value
			if area_backgrounds[area] == 0 then
				drawText("BG-BLK", 144, 2)
			else
				drawText("BG-BLU", 144, 2)
			end

			-- Draw music indicator
			if area_music[area] == 0 then
				drawText("M-OVER", 208, 2)
			elseif area_music[area] == 1 then
				drawText("M-UNDR", 208, 2)
			else
				drawText("M-BOSS", 208, 2)
			end

			-- Draw width and height values
			drawText("W-"..tostring(area_widths[area]), 2, 10)
			drawText("H-"..tostring(area_heights[area]), 56, 10)

			-- Draw currently selected tile
			drawText("T-"..tostring(editor.tile), 120, 10)
			drawTile(editor.tile, 152, 10)

			-- Draw coordinates for edit cursor
			drawText(tostring(editor.cursor_x), 184, 10)
			drawText(",", 216, 10)
			drawText(tostring(editor.cursor_y), 224, 10)

			-- Calculate height and width of edit view
			editor.level_height = area_heights[area] - editor.view_y
			editor.level_width = area_widths[area] - editor.view_x

			if editor.level_height > 208 then
				editor.level_height = 208
			end

			if editor.level_width > 256 then
				editor.level_width = 256
			end

			-- Draw boxes for each square
			for i=0, (editor.level_height / 16) - 1 do
				for j=0, (editor.level_width / 16) - 1 do
					love.graphics.draw(img_editor_16x16_empty, j * 16, 32 + (i * 16))
				end
			end

			-- Draw tiles
			for i=0, (editor.level_height / 16) - 1 do
				for j=0, (editor.level_width / 16) - 1 do
					drawTile(area_tiles[(editor.view_y / 16) + i][(editor.view_x / 16) + j], j * 16, 32 + (i * 16))
				end
			end

			-- Draw edit cursor
			love.graphics.draw(img_editor_16x16_cursor, editor.cursor_x - editor.view_x, editor.cursor_y - editor.view_y + 32)


			--TODO: Add more!
		end

	elseif game_state == "debug" then
	-- Draw debug screen stuff
		drawText("OPENSMB2 DEBUG MODE", 48, 56)
		drawText("F-TOGGLE FPS COUNTER", 48, 80)
		drawText("R-TOGGLE FRAME COUNTER", 48, 96)
		drawText("M-TOGGLE MUSIC MUTE", 48, 112)
		drawText("L-ENTER LEVEL EDITOR", 48, 128)
		drawText("S-START GAME RIGHT NOW", 48, 144)

		drawText("ENABLED FLAGS", 64, 160)

		if debug.fps == true then
			drawText("FPS", 64, 176)
		end

		if debug.frames == true then
			drawText("FRAMES", 104, 176)
		end

		if debug.mute == true then
			drawText("MUTED", 168, 176)
		end
	end

	-- Draw debug stuff
	if debug.mode == true then
		-- Draw FPS
		if debug.fps == true then
			drawText(tostring(love.timer.getFPS()).." FPS", 2, 2)
		end

		-- Draw lasted frames
		if debug.frames == true then
			timerx = 0
			n = timer

			while n > 0 do
				timerx = timerx + 1
				n = math.floor(n / 10)
			end

			drawText(tostring(timer), 256 - (timerx * 8), 2)
		end
	end
end

function loadLevel()
	leveldir = "levels/"..tostring(world).."-"..tostring(level).."/"
	levelfile = love.filesystem.read(leveldir.."settings.cfg")

	-- Get level variables
	all_areas = tonumber(string.sub(levelfile, 7, 7))
	hero_start_x = tonumber(string.sub(levelfile, 16, 19))
	hero_start_y = tonumber(string.sub(levelfile, 28, 31))

	for i=0, all_areas - 1 do
	-- Fill area width, height and background arrays
		areafile = love.filesystem.read(leveldir..tostring(area))

		diff = i * 38

		area_widths[i] = tonumber(string.sub(levelfile, 49 + diff, 52 + diff))
		area_heights[i] = tonumber(string.sub(levelfile, 61 + diff, 64 + diff))
		area_backgrounds[i] = tonumber(string.sub(levelfile, 69 + diff, 69 + diff))
		area_music[i] = tonumber(string.sub(levelfile, 77 + diff, 77 + diff))
	end

	loadArea()
end

function loadArea()
	areafile = love.filesystem.read(leveldir..tostring(area))

	-- Check level background and set it
	if area_backgrounds[area] == 0 then
		utils.setBackgroundColor("black")
	else
		utils.setBackgroundColor("light_blue")
	end

	playAreaMusic()

	for i=0, (area_heights[area] / 16) - 1 do
	-- Fill tile data
	area_tiles[i] = {}
		for j=0, (area_widths[area] / 16) - 1 do
			diff = i * (((area_widths[area] / 16) * 3) + 1)

			area_tiles[i][j] = tonumber(string.sub(areafile, (j * 3) + 1 + diff, (j * 3) + 2 + diff))
		end
	end

	--TODO: Add more!
end

function saveLevel()
	leveldir = "levels/"..tostring(world).."-"..tostring(level).."/"

	-- Convert startx and starty to string variables
	startx_str = utils.toPaddedString(hero_start_x, 4)
	starty_str = utils.toPaddedString(hero_start_y, 4)

	areadata = ""
	areawidth_str = {}
	areaheight_str = {}

	for i=0, all_areas - 1 do
		-- Convert areawidths and areaheights to string variables
		areawidth_str[i] = utils.toPaddedString(area_widths[i], 4)
		areaheight_str[i] = utils.toPaddedString(area_heights[i], 4)

		areadata = areadata..i.." width="..areawidth_str[i].." height="..areaheight_str[i].." bg="..tostring(area_backgrounds[i]).." music="..tostring(area_music[i]).."\n"
	end

	-- Save file with all variables
	data = "areas="..tostring(all_areas).."\nstartx="..startx_str.."\nstarty="..starty_str.."\n\nareas:\n"..areadata
	levelfile = love.filesystem.write(leveldir.."settings.cfg", data)

	saveArea()

	--TODO: Add more!
end

function saveArea()
	areadir = "levels/"..tostring(world).."-"..tostring(level).."/"..tostring(area)

	areadata = ""

	for i=0, (area_heights[area] / 16) - 1 do
	-- Fill file
		for j=0, (area_widths[area] / 16) - 1 do
			areatiles_str = utils.toPaddedString(area_tiles[i][j], 2)

			areadata = areadata..areatiles_str.."."
		end

		areadata = areadata.."\n"
	end

	areafile = love.filesystem.write(areadir, areadata)
end

function playAreaMusic()
	if debug.mute == false then
		if area_music[area] == 0 then
			music_overworld:play()

			music_underworld:stop()
			music_boss:stop()
		elseif area_music[area] == 1 then
			music_underworld:play()

			music_overworld:stop()
			music_boss:stop()
		else
			music_boss:play()

			music_overworld:stop()
			music_underworld:stop()
		end
	end
end

function stopAreaMusic()
	music_overworld:stop()
	music_underworld:stop()
	music_boss:stop()
end

function checkEditCursorBounds()
	if editor.cursor_x > area_widths[area] - 16 then
		editor.cursor_x = area_widths[area] - 16
	end

	if editor.cursor_y > area_heights[area] - 16 then
		editor.cursor_y = area_heights[area] - 16
	end
end

function checkEditGridBounds()
	if editor.cursor_x < editor.view_x then
		editor.view_x = editor.view_x - 16

	elseif editor.cursor_x == editor.view_x + 256 then
		editor.view_x = editor.view_x + 16
	end

	if editor.cursor_y < editor.view_y then
		editor.view_y = editor.view_y - 16

	elseif editor.cursor_y == editor.view_y + 208 then
		editor.view_y = editor.view_y + 16
	end
end

function placeTile(tileid)
	editor.tile_x = editor.cursor_x / 16
	editor.tile_y = editor.cursor_y / 16
	area_tiles[editor.tile_y][editor.tile_x] = tileid
end

function quitEditor()
	editor.option = "select"

	editor.tile = 1

	editor.cursor_x = 0
	editor.cursor_y = 0

	editor.view_x = 0
	editor.view_y = 0

	utils.setBackgroundColor("black")

	stopAreaMusic()
end

function drawText(str, x, y, color)
	realx = 0

	for i=0, string.len(str) - 1 do
		posx = x + (i * 16)
		if realx == 0 then realx = posx end

		code = string.byte(str, i + 1)

		ax = (code % 32) * 16
		ay = math.floor(code / 32) * 16

		if color == "brown" then
			symbol = love.graphics.newQuad(ax, ay, 16, 16, font_brown:getWidth(), font_brown:getHeight())

			love.graphics.draw(font_brown, symbol, realx, y, 0, 0.5)
		else
			symbol = love.graphics.newQuad(ax, ay, 16, 16, font_white:getWidth(), font_white:getHeight())

			love.graphics.draw(font_white, symbol, realx, y, 0, 0.5)
		end

		realx = realx + 8
	end
end

function drawTile(tileid, tilex, tiley)
	ax = (tileid % 16) * 16
	ay = math.floor(tileid / 16) * 16

	tile = love.graphics.newQuad(ax, ay, 16, 16, img_tilemap:getWidth(), img_tilemap:getHeight())

	love.graphics.draw(img_tilemap, tile, tilex, tiley)
end

function drawLevelTiles()
	imin = 0
	imax = 15

	if transition_timer > 0 and transition_timer < 35 then
	-- During transition draw additional row of tiles
		if screen_y > 0 and screendir == - 1 then
		-- Draw additional row of tiles on the top
			imin = -1
		end

		if screen_y <= ((area_heights[area] - 192) / 16 / 12) and screendir == 1 then
		-- Draw additional row of tiles on the bottom
			imax = 16
		end
	end

	for i=imin, imax - 1 do
		for j=0, 16 - 1 do
			if transition_timer > 0 then
			-- Draw tiles when transitioning between screens
				if screen_y == 0 then
					transy = math.floor(transition_timer / 35 * 9)
					tiley = transy + i
					posy = (i * 16) - (transition_timer / 35 * 144) % 16
				else
					if screendir == 1 then
						transy = math.floor(transition_timer / 35 * 9)
						tiley = (screen_y * 9) + transy + i
						posy = (i * 16) - (transition_timer / 35 * 144) % 16

					else
						transy = 9 - math.floor(transition_timer / 35 * 9)
						tiley = ((screen_y - 1) * 9) + transy + i

						posy = (i * 16) + (transition_timer / 35 * 144) % 16
					end
				end
			else
			-- Draw tiles on stationary screen
				if screen_y == 0 then
					tiley = i
				else
					tiley = (screen_y * 9) + i
				end

				posy = i * 16
			end

			tilex = (screen_x * 16) + j

			drawTile(area_tiles[tiley][tilex], j * 16, posy)
		end
	end
end

function remainingLifes()
	if lifes < 10 + 1 then
		str = " "..tostring(lifes - 1)

	elseif lifes < 100 + 1 then
		str = tostring(lifes - 1)

	elseif lifes < 255 + 1 then
		if lifes < 110 + 1 then     letter = "A"
		elseif lifes < 120 + 1 then letter = "B"
		elseif lifes < 130 + 1 then letter = "C"
		elseif lifes < 140 + 1 then letter = "D"
		elseif lifes < 150 + 1 then letter = "E"
		elseif lifes < 160 + 1 then letter = "F"
		elseif lifes < 170 + 1 then letter = "G"
		elseif lifes < 180 + 1 then letter = "H"
		elseif lifes < 190 + 1 then letter = "I"
		elseif lifes < 200 + 1 then letter = "J"
		elseif lifes < 210 + 1 then letter = "K"
		elseif lifes < 220 + 1 then letter = "L"
		elseif lifes < 230 + 1 then letter = "M"
		elseif lifes < 240 + 1 then letter = "N"
		elseif lifes < 250 + 1 then letter = "O"
		else                        letter = "P"
		end

		str = letter..tostring(math.floor((lifes - 1) % 10))
	end

	return str
end

function drawLevelbook()
	love.graphics.draw(img_levelbook, 25, 32)

	drawText("WORLD  "..tostring(world).."-"..tostring(level), 89, 48, "brown")

		if world < 7 then
			all_levels = 3
		else
			all_levels = 2
		end

		for i=0, all_levels - 1 do
		-- Draw level indicators
			if level == i + 1 then
				love.graphics.draw(img_lb_current, 113 + (i * 16), 64)
			else
				love.graphics.draw(img_lb_other, 113 + (i * 16), 64)
			end
		end
end

function drawWorldImage()
	if world == 1 or world == 3 or world == 5 then love.graphics.draw(img_lb_world1, 65, 112)
	elseif world == 2 or world == 6 then           love.graphics.draw(img_lb_world2, 65, 112)
	elseif world == 4 then                         love.graphics.draw(img_lb_world4, 65, 112)
	elseif world == 7 then                         love.graphics.draw(img_lb_world7, 65, 112)
	end
end

function drawCharacter()
	-- Calculate offset for character sprite
	if hero_side == -1 then
		offset = 16

	elseif hero_side == 1 then
		offset = 0
	end

	-- Calculate desired character sprite
	if hero_state == "stationary" then
	-- Calculate sprite if character is walking
		if hero_speed > 0 then
			if hero_animation_timer >= 10 then
				hero_animation_timer = 0
			end

			if hero_animation_timer >= 5 then
				ax = 0 * 16
			else
				ax = 1 * 16
			end

			hero_animation_timer = hero_animation_timer + 1
		else
			ax = 0 * 16

			hero_animation_timer = 0
		end
	elseif character == "luigi" and hero_state == "falling" then
	-- Calculate sprite if character is Luigi and falling
		if hero_animation_timer >= 6 then
			hero_animation_timer = 0
		end

		if hero_animation_timer >= 3 then
			ax = 0 * 16
		else
			ax = 1 * 16
		end

		if transition_timer == 0 then
			hero_animation_timer = hero_animation_timer + 1
		end
	else
		ax = 1 * 16

		hero_animation_timer = 0
	end

	if screen_y == 0 then
		posy = hero_pos_y - screen_y * 240

	else
		posy = hero_pos_y - screen_y * 144
	end

	if transition_timer > 0 then
		if screendir == 1 then posy = posy - (transition_timer / 35) * 144
		else                   posy = posy + (transition_timer / 35) * 144
		end
	end

	-- Draw character sprite
	if character == "mario" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_chars_mario:getWidth(), img_chars_mario:getHeight())

		love.graphics.draw(img_chars_mario, sprite, hero_pos_x, posy, 0, hero_side, 1, offset)

	elseif character == "luigi" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_chars_luigi:getWidth(), img_chars_luigi:getHeight())

		love.graphics.draw(img_chars_luigi, sprite, hero_pos_x, posy, 0, hero_side, 1, offset)

	elseif character == "toad" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_chars_luigi:getWidth(), img_chars_luigi:getHeight())

		love.graphics.draw(img_chars_toad, sprite, hero_pos_x, posy, 0, hero_side, 1, offset)

	elseif character == "peach" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_chars_peach:getWidth(), img_chars_peach:getHeight())

		love.graphics.draw(img_chars_peach, sprite, hero_pos_x, posy, 0, hero_side, 1, offset)
	end

	-- Draw character sprite when it's horizontally wraping
	if hero_pos_x > 256 - 16 then
		if character == "mario" then
			love.graphics.draw(img_chars_mario, sprite, hero_pos_x - area_widths[area], posy, 0, hero_side, 1, offset)

		elseif character == "luigi" then
			love.graphics.draw(img_chars_luigi, sprite, hero_pos_x - area_widths[area], posy, 0, hero_side, 1, offset)

		elseif character == "toad" then
			love.graphics.draw(img_chars_toad, sprite, hero_pos_x - area_widths[area], posy, 0, hero_side, 1, offset)

		elseif character == "peach" then
			love.graphics.draw(img_chars_peach, sprite, hero_pos_x - area_widths[area], posy, 0, hero_side, 1, offset)
		end
	end
end

function screenTrans()
	if transition_timer == 35 then
		transition_timer = 0

		screen_y = screen_y + screendir
	else
		transition_timer = transition_timer + 1
	end
end

function transitionClear()
	transition_timer = 0
	transition = false
end