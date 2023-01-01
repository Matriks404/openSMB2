TSerial = require "source/external/TSerial"

resources = require "source/resources/resources"
world = require "source/world/world"

character = require "source/character"
debug = require "source/debug"
editor = require "source/editor"
filesystem = require "source/filesystem"
game = require "source/game"
state = require "source/state"
utils = require "source/utils"

function love.load()
	GAME_TITLE = "openSMB2"
	GAME_FULL_TITLE = GAME_TITLE.." v"..utils.getVersion()

	-- Game window size (NES resolution)
	GAME_WIDTH = 256
	GAME_HEIGHT = 240

	-- Setting up window
	love.window.setMode(GAME_WIDTH, GAME_HEIGHT, {vsync = true, resizable = true})
	love.window.setTitle(GAME_FULL_TITLE)

	filesystem.setup()

	resources.load()
	state.init()
end

function love.update()
	state.timer = state.timer + 1

	if state.name == "title" then
	-- Title screen stuff
		music_title:play()

		-- After some time go to intro story
		if state.timer == 500 then
			state.name = "intro"
			state.timer = 0
		end

	elseif state.name == "intro" then
	-- Intro story stuff
		if state.transition == true then
			state.transition_timer = state.transition_timer + 1

			-- After some time after showing 2nd story page go to title screen again
			if state.transition_timer == 442 then
				state.name = "title"
				state.timer = 0
				state.text_timer = 0

				story.lines = 0
				story.page = 1

				state.transitionClear()
			end
		end

	elseif state.name == "character_select" then
	-- Character select stuff
		if state.transition == true then
			state.transition_timer = state.transition_timer + 1

			-- After some time after chosing character go to levelbook screen
			if state.transition_timer == 136 then
				state.name = "level_intro"
				state.timer = 0

				music_char_select:stop()
				state.transitionClear()

				-- Chosen character is one that was selected previously by cursor
				if state.cursor == 0 then     character.current = "mario"
				elseif state.cursor == 1 then character.current = "luigi"
				elseif state.cursor == 2 then character.current = "toad"
				elseif state.cursor == 3 then character.current = "peach"
				end
			end
		end

	elseif state.name == "level_intro" then
	-- Levelbook stuff
		if state.timer == 94 then
			state.name = "gameplay"
			state.timer = 0

			world.loadLevel()

			state.screen_y = 0 --TEMPORARY
			character.pos_x = world.start_x
			character.pos_y = world.start_y

			state.char_anim_timer = 0
		end

	elseif state.name == "gameplay" then
	-- Gameplay stuff
		if state.screen_y == 0 and character.pos_y > 192 then
		-- When on first screen, switching vertical screen downwards
			screendir = 1
			state.verticalScreenTransition()

		elseif state.screen_y > 0 then
		-- When on subsequent screen
			if character.pos_y > 192 + state.screen_y * 144 then
			-- Switching vertical screen downwards
				if character.pos_y <= world.area_heights[world.area] - 48 then
				-- If not above lowest screen border switch screen
					screendir = 1
					state.verticalScreenTransition()
				elseif character.pos_y >= world.area_heights[world.area] - 1 then
				-- Die!
					character.dying_timer = character.dying_timer + 1
				end

			elseif character.pos_y < 16 + state.screen_y * 144 then
			-- Switching vertical screen upwords
				screendir = -1
				state.verticalScreenTransition()
			end
		end

		if state.timer > 146 and state.transition_timer == 0 then

			if debug.enabled == true and love.keyboard.isDown("a") then
			-- Ascending
				character.pos_y = character.pos_y - 3.25
			end

			-- Left/Right movement
			if love.keyboard.isDown("left") then
				character.side = -1

				if character.speed == 0 then
					character.movement_dir = -1
				end

				if character.movement_dir == 1 then
					character.speed = character.speed - 4
					character.accel = character.accel - 1
				else
					if character.accel < 6 then
						character.accel = character.accel + 1
					end

					if love.keyboard.isDown("z") then
						character.speed = 6 * character.accel
					else
						character.speed = 4 * character.accel
					end
				end

			elseif love.keyboard.isDown("right") then
				character.side = 1

				if character.speed == 0 then
					character.movement_dir = 1
				end

				if character.movement_dir == -1 then
					character.speed = character.speed - 4
					character.accel = character.accel - 1
				else
					if character.accel < 6 then
						character.accel = character.accel + 1
					end

					if love.keyboard.isDown("z") then
						character.speed = 6 * character.accel
					else
						character.speed = 4 * character.accel
					end
				end

			elseif character.speed > 0 then
			-- Reduce speed after time
				character.speed = character.speed - 4
				character.accel = character.accel - 1
			end

			if character.accel < 0 then
			-- Reseting hero acceleration to 0
				character.accel = 0
			end

			if character.speed > 0 then
				-- Calculating character position
				character.subpos_x = character.subpos_x + character.speed * character.movement_dir

				while character.subpos_x >= 16 or character.subpos_x <= -16 do
					character.subpos_x = character.subpos_x - 16 * character.movement_dir
					character.pos_x = character.pos_x + character.movement_dir
				end

				-- Horizontal character position wraping
				if character.pos_x > world.area_widths[world.area] then
					character.pos_x = 0 + character.pos_x % world.area_widths[world.area]

				elseif character.pos_x < 0 then
					character.pos_x = world.area_widths[world.area] + character.pos_x
				end

			elseif character.speed < 0 then
			-- Reset hero speed to 0
				character.speed = 0
			end

			-- Character falling (slower for Luigi) --TEMPORARY
			if character.current == "luigi" then
				character.pos_y = character.pos_y + 2.5
			else
				character.pos_y = character.pos_y + 3
			end

			if character.dying_timer == 6 then
			-- Deplate energy and play death sound
				character.energy = 0

				music.stop()
				sfx_death:play()
			end

			if character.dying_timer == 84 then
			-- Die!
				state.timer = 0
				character.dying_timer = 0

				character.lives = character.lives - 1 -- Decrement a life

				if character.lives > 0 then
				-- Going to death screen and playing once more
					character.energy = 2 -- Reset energy

					-- Reset character position and side
					state.screen_y = 0 --TEMPORARY
					character.pos_x = world.start_x
					character.pos_y = world.start_y
					character.side = 1

					state.name = "death"
				else
				-- No more lifes, go to game over screen
					sfx_game_over:play()

					if character.continues > 0 then
						state.cursor = 0
					else
						state.cursor = 1
					end

					state.name = "game_over"
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
	if state.name == "title" or state.name == "intro" or state.name == "debug" then
		if key == "s" then
		-- Go to character screen
			state.name = "character_select"
			state.timer = 0

			music_title:stop()
			state.transitionClear()

			if debug.mute == false then
				music_char_select:play()
			end

			state.resetGame()

			graphics.setBackgroundColor("black")

		elseif love.keyboard.isDown("lctrl") and key == "d" then
		-- Go to debug screen or title screen (depending on origin screen)
			if debug.enabled == false then
				state.name = "debug"
				state.timer = 0

				debug.enabled = true

				music_title:stop()
			else
				state.name = "title"
				state.timer = 0

				debug.enabled = false
				debug.mute = false
			end
		end
	end

	if state.name == "character_select" then
	-- Character select screen
		if key == "left" and state.transition_timer == 0 then
		-- Select character on the left
			if state.cursor > 0 then
				state.cursor = state.cursor - 1
			else
				state.cursor = 3
			end

			sfx_cherry:play()

		elseif key == "right" and state.transition_timer == 0 then
		-- Select character on the right
			if state.cursor < 3 then
				state.cursor = state.cursor + 1
			else
				state.cursor = 0
			end

			sfx_cherry:play()

		elseif key == "x" and state.transition_timer == 0 then
		-- Choose character and enable transition which will go to levelbook after some time
			state.transition = true

			sfx_cherry:play()
		end

	elseif state.name == "gameplay" then
	-- Gameplay screen
		if key == "s" and state.timer > 146 and state.transition_timer == 0 then
		-- Go to pause screen
			state.name = "pause"

			state.backup_timer = state.timer
			state.timer = 0
		end

		if debug.enabled == true then
			if key == "d" then
			-- Die!
				character.dying_timer = 84

				stopAreaMusic()
			end
		end

	elseif state.name == "pause" then
	-- Pause screen
		if key == "s" then
		-- Go back to gameplay
			state.name = "gameplay"

			state.timer = state.backup_timer -- Backup gameplay timer
			state.transition_timer = 0
		end

	elseif state.name == "game_over" then
	-- Game over screen
		if key == "a" and character.continues > 0 then
		-- Select option
			if state.cursor == 0 then
				state.cursor = 1
			else
				state.cursor = 0
			end
		end

		if key == "s" then
			if state.cursor == 0 then
				character.continues = character.continues - 1
				character.lives = 3
				character.energy = 2

				music_char_select:play()

				state.name = "character_select"
			else
				utils.setBackgroundColor("blue")

				state.cursor = 0
				state.timer = 0
				state.name = "title"
			end
		end

	elseif state.name == "editor" then
	-- Level editor screen
		if editor.option == "select" then
		-- Level select
			-- Set world according to world table
			if key >= "1" and key <= "3" then                  world.current = 1
			elseif key >= "4" and key <= "6" then              world.current = 2
			elseif key >= "7" and key <= "9" then              world.current = 3
			elseif key == "a" or key == "b" or key == "c" then world.current = 4
			elseif key == "d" or key == "e" or key == "f" then world.current = 5
			elseif key == "g" or key == "h" or key == "i" then world.current = 6
			elseif key == "j" or key == "k" then               world.current = 7
			end

			-- Go to proper editor
			if key >= "1" and key <= "9" then
				editor.option = "edit"
				world.level = ((key - 1) % 3) + 1
				world.area = 0

				world.loadLevel()

			elseif string.byte(key) >= string.byte("a") and string.byte(key) <= string.byte("k") then
				editor.option = "edit"
				world.level = ((string.byte(key) - 97) % 3) + 1
				world.area = 0

				world.loadLevel()

			elseif key == "q" then
			-- Quit menu to debug screen
				state.name = "debug"
				state.timer = 0

				graphics.setBackgroundColor("blue")
			end

		elseif editor.option == "edit" then
		-- Edit map option
			if key == "b" then
			-- Change background color
				if world.area_backgrounds[world.area] == 0 then
					world.area_backgrounds[world.area] = 1

					graphics.setBackgroundColor("light_blue")
				else
					world.area_backgrounds[world.area] = 0

					graphics.setBackgroundColor("black")
				end

			elseif key == "m" then
			-- Change music
				if world.area_music[world.area] < 2 then
					world.area_music[world.area] = world.area_music[world.area] + 1

					music.play()
				else
					world.area_music[world.area] = 0

					music.play()
				end

			-- Shrink or scratch width/height
			elseif key == "kp4" then
				if world.area_widths[world.area] > 16 then
					world.area_widths[world.area] = world.area_widths[world.area] - 16

					editor.checkCursorBounds()
					editor.checkGridBounds()
				end

			elseif key == "kp6" then
				if world.area_widths[world.area] < 3744 then
					world.area_widths[world.area] = world.area_widths[world.area] + 16

					editor.checkCursorBounds()
					editor.checkGridBounds()

					for i=0, (world.area_heights[world.area] / 16) - 1 do
					-- Clear newly added tile blocks
						world.area_tiles[i][(world.area_widths[world.area] / 16) - 1] = 0
					end
				end

			elseif key == "kp8" then
				if world.area_heights[world.area] > 16 then
					world.area_heights[world.area] = world.area_heights[world.area] - 16

					editor.checkCursorBounds()
					editor.checkGridBounds()
				end

			elseif key == "kp2" then
				if world.area_heights[world.area] < 1440 then
					world.area_heights[world.area] = world.area_heights[world.area] + 16

					editor.checkCursorBounds()
					editor.checkGridBounds()

					-- Clear newly added tile blocks
					world.area_tiles[(world.area_heights[world.area] / 16) - 1] = {}

					for j=0, (world.area_widths[world.area] / 16) - 1 do
						world.area_tiles[(world.area_heights[world.area] / 16) - 1][j] = 0
					end
				end

			-- Change current areas
			elseif key == "[" then
				world.saveLevel()

				if world.area > 0 then
					world.area = world.area - 1

				else
					world.area  = world.area_count - 1

				end

				world.loadArea()

				editor.cursor_x = 0
				editor.cursor_y = 0

				editor.view_x = 0
				editor.view_y = 0

			elseif key == "]" then
				world.saveLevel()

				if world.area < world.area_count - 1 then
					world.area = world.area + 1
				else
					world.area = 0
				end

				world.loadArea()

				editor.cursor_x = 0
				editor.cursor_y = 0

				editor.view_x = 0
				editor.view_y = 0

			-- Move edit cursor
			elseif key == "left" and editor.cursor_x > 0 then
				editor.cursor_x = editor.cursor_x - 16

				editor.checkGridBounds()

			elseif key == "right" and editor.cursor_x < world.area_widths[world.area] - 16 then
				editor.cursor_x = editor.cursor_x + 16

				editor.checkGridBounds()

			elseif key == "up" and editor.cursor_y > 0 then
				editor.cursor_y = editor.cursor_y - 16

				editor.checkGridBounds()

			elseif key == "down" and editor.cursor_y < world.area_heights[world.area] - 16 then
				editor.cursor_y = editor.cursor_y + 16

				editor.checkGridBounds()

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
				editor.placeTile(0)

			elseif key == "x" then
			-- Place tile
				editor.placeTile(editor.tile)

			elseif key == "l" then
			-- Load this level from file
				world.loadLevel()

			elseif key == "v" then
			-- Save this level to file
				world.saveLevel()

			elseif key == "p" then
			-- Play from this level (doesn't return to level editor)
				world.saveLevel()

				state.name = "character_select"
				world.area = 0
				frames = 0

				if debug.mute == false then
					music.stop()
					music_char_select:play()
				end

				graphics.setBackgroundColor("black")

			elseif key == "q" then
			-- Quit to editor menu
				editor.quit()

			elseif key == "e" then
			-- Quit to editor menu and save level
				world.saveLevel()
				world.quit()
			end
		end

	elseif state.name == "debug" then
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
			state.name = "editor"
			state.timer = 0

			debug.frames = false
			editor.option = "select"

			graphics.setBackgroundColor("black")
		end
	end
end

function love.draw()
	if state.name == "title" or state.name == "intro" or state.name == "debug" then
	-- Draw border on title screen and intro
		love.graphics.draw(img_title_border, 0, 0)
	end

	if state.name == "title" then
	-- Draw title screen stuff
		love.graphics.draw(img_title_logo, 48, 48)

		graphics.drawText("!\"", 193, 72)
		graphics.drawText("#1988 NINTENDO", 72, 184)

	elseif state.name == "intro" then
	-- Draw intro story stuff
		if state.timer > 34 then
			graphics.drawText("STORY", 112, 40)

			if state.text_timer > 65 then
			-- Based on timer add new line of text
				story.lines = story.lines + 1
				state.text_timer = 0

				if story.page == 1 and story.lines > 8 then
				-- Change to 2nd story page if all lines are displayed
					story.lines = 0
					story.page = 2
					state.text_timer = 50

				elseif story.page == 2 and story.lines > 8 then
				-- Enable transition which will go to title screen after some time
					story.lines = 8
					state.transition = true
				end
			end

			state.text_timer = state.text_timer + 1

			for i=0, story.lines do
			-- Draw lines of text
				graphics.drawText(tostring(story[story.page][i]), 48, 64 + ((i - 1) * 16))
			end
		end

	elseif state.name == "character_select" then
	-- Draw character select screen stuff
		love.graphics.draw(img_cs_border, 0, 0)

		graphics.drawText("PLEASE SELECT", 72, 80)
		graphics.drawText("PLAYER", 96, 96)

		love.graphics.draw(img_cs_arrow, 72 + (state.cursor * 32), 112)

		if state.cursor == 0 then
		-- Draw Mario
			if state.transition_timer < 3 or state.transition_timer > 68 then
				love.graphics.draw(img_cs_mario_active, 72, 144)
			else
				love.graphics.draw(img_cs_mario_select, 72, 144)
			end
		else
			love.graphics.draw(img_cs_mario, 72, 144)
		end

		if state.cursor == 1 then
		-- Draw Luigi
			if state.transition_timer < 3 or state.transition_timer > 68 then
				love.graphics.draw(img_cs_luigi_active, 104, 144)
			else
				love.graphics.draw(img_cs_luigi_select, 104, 144)
			end
		else
			love.graphics.draw(img_cs_luigi, 104, 144)
		end

		if state.cursor == 2 then
		-- Draw Toad
			if state.transition_timer < 3 or state.transition_timer > 68 then
				love.graphics.draw(img_cs_toad_active, 136, 144)
			else
				love.graphics.draw(img_cs_toad_select, 136, 144)
			end
		else
			love.graphics.draw(img_cs_toad, 136, 144)
		end

		if state.cursor == 3 then
		-- Draw Peach
			if state.transition_timer < 3 or state.transition_timer > 68 then
				love.graphics.draw(img_cs_peach_active, 168, 144)
			else
				love.graphics.draw(img_cs_peach_select, 168, 144)
			end
		else
			love.graphics.draw(img_cs_peach, 168, 144)
		end

		graphics.drawText("EXTRA LIFE", 64, 208)
		graphics.drawText(game.getRemainingLives(character.lives), 176, 208)

	elseif state.name == "level_intro" then
		graphics.drawLevelbook() -- Draw levelbook

		graphics.drawWorldImage() -- Draw world image

	elseif state.name == "gameplay" then
	-- Draw gameplay stuff

		if state.timer > 144 then graphics.drawLevelTiles() -- Draw level tiles
		end

		if state.timer > 146 then
		-- Draw everything else
			if state.timer == 147 then
				sfx_fall:play() -- Play falling sound
			end

			for i=0, character.energy_bars - 1 do
			-- Draw energy bars
				if i+1 <= character.energy then
					love.graphics.draw(img_gp_filled, 12, 48 + (i * 16))
				else
					love.graphics.draw(img_gp_empty, 12, 48 + (i * 16))
				end
			end

			graphics.drawCharacter() -- Draw character on screen

			--TODO: Draw entities
		end

	elseif state.name == "pause" then
	-- Draw pause screen stuff
		graphics.drawLevelbook() -- Draw levelbook

		-- Draw flickering pause text
		if state.transition_timer == 30 then
			state.transition_timer = 0

		elseif state.transition_timer >= 15 then
			graphics.drawText("PAUSED", 105, 120, "brown")
		end

		graphics.drawText("EXTRA LIFE*** "..game.getRemainingLives(character.lives), 65, 176, "brown") -- Draw extra lifes text

		state.transition_timer = state.transition_timer + 1

	elseif state.name == "death" then
	-- Draw dying screen stuff

		graphics.drawLevelbook() -- Draw levelbook

		graphics.drawText("EXTRA LIFE*** "..game.getRemainingLives(character.lives), 65, 80, "brown") -- Draw remaining lifes

		graphics.drawWorldImage() -- Draw world image

		if state.timer >= 120 then
		-- Go to gameplay once again!
			state.name = "gameplay"
			state.timer = 0

			music.play()
		end

	elseif state.name == "game_over" then
	-- Draw game over screen stuff
		if state.timer < 192 then
			graphics.drawText("GAME  OVER", 88, 112)
		else
			-- Draw text
			if character.continues > 0 then
				graphics.drawText("CONTINUE "..tostring(character.continues), 96, 88)
			end

			graphics.drawText("RETRY", 96, 104)

			love.graphics.draw(img_indicator, 81, 89 + state.cursor * 16)
		end

	elseif state.name == "editor" then
	-- Draw level editor stuff
		if editor.option == "select" then
		-- Draw level editor menu
			graphics.drawText(string.upper(GAME_FULL_TITLE), 32, 32)
			graphics.drawText("LEVEL EDITOR", 32, 48)

			graphics.drawText("LEVEL SELECT", 32, 80)

			graphics.drawText(" 1 - 1-1  4 - 2-1  7 - 3-1", 32, 96)
			graphics.drawText(" 2 - 1-2  5 - 2-2  8 - 3-2", 32, 112)
			graphics.drawText(" 3 - 1-3  6 - 2-3  9 - 3-3", 32, 128)

			graphics.drawText(" A - 4-1  D - 5-1  G - 6-1", 32, 160)
			graphics.drawText(" B - 4-2  E - 5-2  H - 6-2", 32, 176)
			graphics.drawText(" C - 4-3  F - 5-3  I - 6-3", 32, 192)

			graphics.drawText(" J - 7-1  K - 7-2  Q - QUIT", 32, 224)

		elseif editor.option == "edit" then
		-- Draw editor
			-- Draw world, level and area indicators
			graphics.drawText(tostring(world.current).."-"..tostring(world.level), 64, 2)
			graphics.drawText("A-"..tostring(world.area), 104, 2)

			-- Draw background value
			if world.area_backgrounds[world.area] == 0 then
				graphics.drawText("BG-BLK", 144, 2)
			else
				graphics.drawText("BG-BLU", 144, 2)
			end

			-- Draw music indicator
			if world.area_music[world.area] == 0 then
				graphics.drawText("M-OVER", 208, 2)
			elseif world.area_music[world.area] == 1 then
				graphics.drawText("M-UNDR", 208, 2)
			else
				graphics.drawText("M-BOSS", 208, 2)
			end

			-- Draw width and height values
			graphics.drawText("W-"..tostring(world.area_widths[world.area]), 2, 10)
			graphics.drawText("H-"..tostring(world.area_heights[world.area]), 56, 10)

			-- Draw currently selected tile
			graphics.drawText("T-"..tostring(editor.tile), 120, 10)
			graphics.drawTile(editor.tile, 152, 10)

			-- Draw coordinates for edit cursor
			graphics.drawText(tostring(editor.cursor_x), 184, 10)
			graphics.drawText(",", 216, 10)
			graphics.drawText(tostring(editor.cursor_y), 224, 10)

			-- Calculate height and width of edit view
			editor.level_height = world.area_heights[world.area] - editor.view_y
			editor.level_width = world.area_widths[world.area] - editor.view_x

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
					graphics.drawTile(world.area_tiles[(editor.view_y / 16) + i][(editor.view_x / 16) + j], j * 16, 32 + (i * 16))
				end
			end

			-- Draw edit cursor
			love.graphics.draw(img_editor_16x16_cursor, editor.cursor_x - editor.view_x, editor.cursor_y - editor.view_y + 32)


			--TODO: Add more!
		end

	elseif state.name == "debug" then
	-- Draw debug screen stuff
		graphics.drawText("OPENSMB2 DEBUG MODE", 48, 56)
		graphics.drawText("F-TOGGLE FPS COUNTER", 48, 80)
		graphics.drawText("R-TOGGLE FRAME COUNTER", 48, 96)
		graphics.drawText("M-TOGGLE MUSIC MUTE", 48, 112)
		graphics.drawText("L-ENTER LEVEL EDITOR", 48, 128)
		graphics.drawText("S-START GAME RIGHT NOW", 48, 144)

		graphics.drawText("ENABLED FLAGS", 64, 160)

		if debug.fps == true then
			graphics.drawText("FPS", 64, 176)
		end

		if debug.frames == true then
			graphics.drawText("FRAMES", 104, 176)
		end

		if debug.mute == true then
			graphics.drawText("MUTED", 168, 176)
		end
	end

	-- Draw debug stuff
	if debug.enabled == true then
		-- Draw FPS
		if debug.fps == true then
			graphics.drawText(tostring(love.timer.getFPS()).." FPS", 2, 2)
		end

		-- Draw lasted frames
		if debug.frames == true then
			timerx = 0
			n = state.timer

			while n > 0 do
				timerx = timerx + 1
				n = math.floor(n / 10)
			end

			graphics.drawText(tostring(state.timer), 256 - (timerx * 8), 2)
		end
	end
end