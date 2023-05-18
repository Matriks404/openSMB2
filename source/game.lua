local game = {}

function game.load(id)
	local gamepack = launcher.gamepacks[id]

	game.directory = gamepack.directory
	game.name = gamepack.name
	game.version = gamepack.version
	--game.levelpack = gamepack.default_levelpack --TODO: Implement levelpacks.
	game.font1 = gamepack.font1
	game.font2 = gamepack.font2
	game.title_text = gamepack.title_text

	love.window.setTitle(app.title.." - "..game.name)

	game_resources.load(game.directory)
	graphics.loadWorldImages()

	editor.loadImages()

	game.setupStates()
	state.set("title")
end

function game.reset()
	world.reset()
	character.reset()
end

--TODO: Refactor this!
function game.update()
	if state.name == "title" then
		title.update()

	elseif state.name == "character_select" then
		if state.transition then
			state.transition_timer = state.transition_timer + 1

			-- After some time after chosing character go to levelbook screen
			if state.transition_timer == 136 then
				state.set("level_intro")
				state.transitionClear()

				-- Chosen character is one that was selected previously by cursor
				if state.cursor == 0 then     character.current = "char1"
				elseif state.cursor == 1 then character.current = "char2"
				elseif state.cursor == 2 then character.current = "char3"
				elseif state.cursor == 3 then character.current = "char4"
				end
			end
		end

	elseif state.name == "level_intro" then
		if state.timer == 94 then
			state.set("gameplay")

			world.enter(world.current, world.level, world.area)

			state.screen_y = 0 --TEMPORARY
			character.pos_x = world.current_level.start_x
			character.pos_y = world.current_level.start_y

			state.char_anim_timer = 0
		end

	elseif state.name == "gameplay" then
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
			if debugging.enabled and love.keyboard.isDown("lctrl", "rctrl") and love.keyboard.isDown("a") then
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
			-- Reseting character acceleration to 0
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
			-- Reseting character speed to 0
				character.speed = 0
			end

			-- Character falling (slower for Luigi) --TEMPORARY
			if character.current == "char2" then
				character.pos_y = character.pos_y + 2.5
			else
				character.pos_y = character.pos_y + 3
			end

			if character.dying_timer == 6 then
			-- Deplate energy and play death sound
				character.energy = 0

				game_resources.music.stopAll()

				if game_resources.sound.death then
					game_resources.sound.play("death")
				end
			end

			if character.dying_timer == 84 then
			-- Die!
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

					state.set("death")
				else
				-- No more lifes, go to game over screen
					if game_resources.sound.game_over then
						game_resources.sound.play("game_over")
					end

					state.cursor = (character.continues > 0 and 0) or 1

					state.set("game_over")
				end
			end
		end
	end
end

--TODO: Refactor this!
function game.draw()
	if state.name == "launcher" then
		launcher.draw()
	elseif state.name == "title" then
		title.draw()

	elseif state.name == "character_select" then
		if game_resources.images.cs_border then
			love.graphics.draw(game_resources.images.cs_border, 0, 0)
		end

		graphics.drawText("PLEASE SELECT", 72, 80)
		graphics.drawText("PLAYER", 96, 96)

		love.graphics.draw(game_resources.images.cs_arrow, 72 + (state.cursor * 32), 112)

		local char1, char2, char3, char4

		-- Character 1
		if state.cursor == 0 then
			if state.transition_timer < 3 or state.transition_timer > 68 then
				char1 = game_resources.images.cs_char1_active
			else
				char1 = game_resources.images.cs_char1_select
			end
		else
			char1 = game_resources.images.cs_char1
		end

		-- Character 2
		if state.cursor == 1 then
			if state.transition_timer < 3 or state.transition_timer > 68 then
				char2 = game_resources.images.cs_char2_active
			else
				char2 = game_resources.images.cs_char2_select
			end
		else
			char2 = game_resources.images.cs_char2
		end

		-- Character 3
		if state.cursor == 2 then
			if state.transition_timer < 3 or state.transition_timer > 68 then
				char3 = game_resources.images.cs_char3_active
			else
				char3 = game_resources.images.cs_char3_select
			end
		else
			char3 = game_resources.images.cs_char3
		end

		-- Character 4
		if state.cursor == 3 then
			if state.transition_timer < 3 or state.transition_timer > 68 then
				char4 = game_resources.images.cs_char4_active
			else
				char4 = game_resources.images.cs_char4_select
			end
		else
			char4 = game_resources.images.cs_char4
		end

		if char1 then
			love.graphics.draw(char1, 72, 144)
		end

		if char2 then
			love.graphics.draw(char2, 104, 144)
		end

		if char3 then
			love.graphics.draw(char3, 136, 144)
		end

		if char4 then
			love.graphics.draw(char4, 168, 144)
		end

		graphics.drawText("EXTRA LIFE", 64, 208)
		graphics.drawText(game.getRemainingLives(character.lives), 176, 208)

	elseif state.name == "level_intro" then
		graphics.drawLevelbook() -- Draw levelbook

		graphics.drawWorldImage() -- Draw world image

	elseif state.name == "gameplay" then
		if state.timer > 144 then
			graphics.drawLevelTiles() -- Draw level tiles
		end

		if state.timer > 146 then
		-- Draw everything else
			if state.timer == 147 and game_resources.sound.fall then
				game_resources.sound.play("fall")
			end

			if game_resources.images.gp_empty and game_resources.images.gp_filled then
				for i = 1, character.energy_bars do
				-- Draw energy bars
					local gp = (i <= character.energy and game_resources.images.gp_filled) or game_resources.images.gp_empty

					love.graphics.draw(gp, 12, 48 + ((i - 1) * 16))
				end
			end

			graphics.drawCharacter() -- Draw character on screen

			--TODO: Draw entities
		end

	elseif state.name == "pause" then
		graphics.drawLevelbook() -- Draw levelbook

		-- Draw flickering pause text
		if state.transition_timer == 30 then
			state.transition_timer = 0

		elseif state.transition_timer >= 15 then
			graphics.drawText("PAUSED", 105, 120)
		end

		graphics.drawText("EXTRA LIFE*** "..game.getRemainingLives(character.lives), 65, 176) -- Draw extra lifes text

		state.transition_timer = state.transition_timer + 1

	elseif state.name == "death" then
		graphics.drawLevelbook() -- Draw levelbook
		graphics.drawText("EXTRA LIFE*** "..game.getRemainingLives(character.lives), 65, 80) -- Draw remaining lifes
		graphics.drawWorldImage() -- Draw world image

		if state.timer >= 120 then
		-- Go to gameplay once again!
			state.set("gameplay")

			world.enter(world.current, world.level, world.area)
		end

	elseif state.name == "game_over" then
		if state.timer < 192 then
			graphics.drawText("GAME  OVER", 88, 112)
		else
			-- Draw text
			if character.continues > 0 then
				graphics.drawText("CONTINUE "..tostring(character.continues), 96, 88)
			end

			graphics.drawText("RETRY", 96, 104)

			love.graphics.draw(game_resources.images.indicator, 81, 89 + state.cursor * 16)
		end

	elseif state.name == "level_editor_menu" then
		editor.draw.menu()

	elseif state.name == "level_editor" then
		editor.draw.editor()
	end

	debugging.drawInfo()
end

function game.setupStates()
	state.setupState("title", "blue", game.font1, "title")
	state.setupState("character_select", "black", game.font1, "character_select")
	state.setupState("level_intro", "black", game.font2, nil)
	state.setupState("gameplay", "LEVEL_SPECIFIC", game.font1, "LEVEL_SPECIFIC")
	state.setupState("pause", "black", game.font2, "LEVEL_SPECIFIC")
	state.setupState("death", "black", game.font2, nil)
	state.setupState("game_over", "black", game.font1, nil)
	state.setupState("level_editor_menu", "black", game.font1, nil)
	state.setupState("level_editor", "LEVEL_SPECIFIC", game.font1, "LEVEL_SPECIFIC")
end

function game.getRemainingLives(lives)
	local str, letter

	local lives = lives - 1

	if lives < 10 then
		str = " "..tostring(lives)

	elseif lives < 100 then
		str = tostring(lives)

	elseif lives < 255 then
		local tens_digit = math.floor((lives - 100) / 10)
		local letter = string.char(tens_digit + 65)

		local digit = tostring((lives) % 10)

		str = letter..digit
	end

	return str
end

return game