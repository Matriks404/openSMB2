TSerial = require "source/external/TSerial"

resources = require "source/resources/resources"
utils = require "source/utils"

character = require "source/character"
data = require "source/data"
debugging = require "source/debugging"
editor = require "source/editor"
filesystem = require "source/filesystem"
game = require "source/game"
graphics = require "source/graphics"
input = require "source/input"
music = require "source/music"
state = require "source/state"
window = require "source/window"
world = require "source/world"

function love.load()
	window.setup()

	filesystem.setup()

	graphics.init()
	resources.load()
	music.init()

	music.play("title")
end


function love.update()
	state.timer = state.timer + 1

	if state.name == "title" then
	-- Title screen stuff
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
		music.play("character_select")

		if state.transition == true then
			state.transition_timer = state.transition_timer + 1

			-- After some time after chosing character go to levelbook screen
			if state.transition_timer == 136 then
				state.name = "level_intro"
				state.timer = 0

				music.stopAll()
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

			world.enter(world.current, world.level, world.area)

			state.screen_y = 0 --TEMPORARY
			character.pos_x = world.current_level.start_x
			character.pos_y = world.current_level.start_y

			state.char_anim_timer = 0
		end

	elseif state.name == "gameplay" then
	-- Gameplay stuff
		if state.screen_y == 0 and character.pos_y > 192 then
		-- When on first screen, switching vertical screen downwards
			state.screen_dir = 1
			state.verticalScreenTransition()

		elseif state.screen_y > 0 then
		-- When on subsequent screen
			if character.pos_y > 192 + state.screen_y * 144 then
			-- Switching vertical screen downwards
				if character.pos_y <= world.current_area.height - 48 then
				-- If not above lowest screen border switch screen
					state.screen_dir = 1
					state.verticalScreenTransition()
				elseif character.pos_y >= world.current_area.height - 1 then
				-- Die!
					character.dying_timer = character.dying_timer + 1
				end

			elseif character.pos_y < 16 + state.screen_y * 144 then
			-- Switching vertical screen upwards
				state.screen_dir = -1
				state.verticalScreenTransition()
			end
		end

		if state.timer > 146 and state.transition_timer == 0 then
			if debugging.enabled and love.keyboard.isDown("a") then
			-- Ascending
				character.pos_y = character.pos_y - 6
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
				if character.pos_x > world.current_area.width then
					character.pos_x = 0 + character.pos_x % world.current_area.width

				elseif character.pos_x < 0 then
					character.pos_x = world.current_area.width + character.pos_x
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

				music.stopAll()
				snd.sfx_death:play()
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
					character.pos_x = world.current_level.start_x
					character.pos_y = world.current_level.start_y
					character.side = 1

					state.name = "death"
				else
				-- No more lifes, go to game over screen
					snd.sfx_game_over:play()

					if character.continues > 0 then
						state.cursor = 0
					else
						state.cursor = 1
					end

					state.name = "game_over"
				end
			end
		end
	end
end

function love.keyreleased(key)
	input.check(key)
end

function love.draw()
	love.graphics.scale(graphics.scale, graphics.scale)

	if state.name == "title" or state.name == "intro" or state.name == "debug" then
	-- Draw border on title screen and intro
		love.graphics.draw(img.title_border, 0, 0)
	end

	if state.name == "title" then
	-- Draw title screen stuff
		love.graphics.draw(img.title_logo, 48, 48)

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
		love.graphics.draw(img.cs_border, 0, 0)

		graphics.drawText("PLEASE SELECT", 72, 80)
		graphics.drawText("PLAYER", 96, 96)

		love.graphics.draw(img.cs_arrow, 72 + (state.cursor * 32), 112)

		if state.cursor == 0 then
		-- Draw Mario
			if state.transition_timer < 3 or state.transition_timer > 68 then
				love.graphics.draw(img.cs_mario_active, 72, 144)
			else
				love.graphics.draw(img.cs_mario_select, 72, 144)
			end
		else
			love.graphics.draw(img.cs_mario, 72, 144)
		end

		if state.cursor == 1 then
		-- Draw Luigi
			if state.transition_timer < 3 or state.transition_timer > 68 then
				love.graphics.draw(img.cs_luigi_active, 104, 144)
			else
				love.graphics.draw(img.cs_luigi_select, 104, 144)
			end
		else
			love.graphics.draw(img.cs_luigi, 104, 144)
		end

		if state.cursor == 2 then
		-- Draw Toad
			if state.transition_timer < 3 or state.transition_timer > 68 then
				love.graphics.draw(img.cs_toad_active, 136, 144)
			else
				love.graphics.draw(img.cs_toad_select, 136, 144)
			end
		else
			love.graphics.draw(img.cs_toad, 136, 144)
		end

		if state.cursor == 3 then
		-- Draw Peach
			if state.transition_timer < 3 or state.transition_timer > 68 then
				love.graphics.draw(img.cs_peach_active, 168, 144)
			else
				love.graphics.draw(img.cs_peach_select, 168, 144)
			end
		else
			love.graphics.draw(img.cs_peach, 168, 144)
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
				snd.sfx_fall:play() -- Play falling sound
			end

			for i=0, character.energy_bars - 1 do
			-- Draw energy bars
				if i+1 <= character.energy then
					love.graphics.draw(img.gp_filled, 12, 48 + (i * 16))
				else
					love.graphics.draw(img.gp_empty, 12, 48 + (i * 16))
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

			music.play(world.current_area.music)
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

			love.graphics.draw(img.indicator, 81, 89 + state.cursor * 16)
		end

	elseif state.name == "level_editor" then
		editor.draw()

	elseif state.name == "debug" then
	-- Draw debug screen stuff
		graphics.drawText("OPENSMB2 DEBUG MODE", 48, 56)
		graphics.drawText("F-TOGGLE FPS COUNTER", 48, 80)
		graphics.drawText("R-TOGGLE FRAME COUNTER", 48, 96)
		graphics.drawText("M-TOGGLE MUSIC MUTE", 48, 112)
		graphics.drawText("L-ENTER LEVEL EDITOR", 48, 128)
		graphics.drawText("S-START GAME RIGHT NOW", 48, 144)

		graphics.drawText("ENABLED FLAGS", 64, 160)

		if debugging.fps then
			graphics.drawText("FPS", 64, 176)
		end

		if debugging.frames then
			graphics.drawText("FRAMES", 104, 176)
		end

		if debugging.mute then
			graphics.drawText("MUTED", 168, 176)
		end
	end

	-- Draw debug stuff
	if debugging.enabled then
		-- Draw FPS
		if debugging.fps then
			graphics.drawText(tostring(love.timer.getFPS()).." FPS", 2, 2)
		end

		-- Draw lasted frames
		if debugging.frames then
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