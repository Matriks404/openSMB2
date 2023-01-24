local input = {}

function input.check(key)
	-- Quit if user pressed ESC key
	if key == "escape" then
		love.event.quit()

	elseif ((love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) and key == "return") or key == "f11" then
		window.updateFullscreen()

	elseif key == "-" then
		graphics.scaleDown()

	elseif key == "=" then
		graphics.scaleUp()
	end

	-- Title screen, intro story or debug screen
	if state.name == "title" or state.name == "intro" or state.name == "debug" then
		if key == "s" then
		-- Go to character screen
			state.name = "character_select"
			state.timer = 0

			state.transitionClear()
			state.resetGame()

			graphics.setBackgroundColor("black")

		elseif (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and key == "d" then
		-- Go to debug screen or title screen (depending on origin screen)
			if debugging.enabled then
				state.name = "title"
				state.timer = 0

				debugging.enabled = false
				debugging.mute = false

				music.play("title")
			else
				state.name = "debug"
				state.timer = 0

				debugging.enabled = true

				music.stopAll()
			end
		end
	end

	if state.name == "character_select" then
	-- Character select screen
		if key == "left" and state.transition_timer == 0 then
		-- Select character on the left
			state.cursor = (state.cursor > 0 and state.cursor - 1) or 3

			snd.sfx_cherry:play()

		elseif key == "right" and state.transition_timer == 0 then
		-- Select character on the right
			state.cursor = (state.cursor < 3 and state.cursor + 1) or 0

			snd.sfx_cherry:play()

		elseif key == "x" and state.transition_timer == 0 then
		-- Choose character and enable transition which will go to levelbook after some time
			state.transition = true

			snd.sfx_cherry:play()
		end

	elseif state.name == "gameplay" then
	-- Gameplay screen
		if key == "s" and state.timer > 146 and state.transition_timer == 0 then
		-- Go to pause screen
			state.name = "pause"

			state.backup_timer = state.timer
			state.timer = 0
		end

		if debugging.enabled and key == "d" then
		-- Die!
			character.dying_timer = 84

			music.stopAll()
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
			state.cursor = (state.cursor == 0 and 1) or 0
		end

		if key == "s" then
			if state.cursor == 0 then
				character.continues = character.continues - 1
				character.lives = 3
				character.energy = 2

				state.name = "character_select"
			else
				graphics.setBackgroundColor("blue")

				state.cursor = 0
				state.timer = 0
				state.name = "title"

				music.play("title")
			end
		end

	elseif state.name == "level_editor" then
		if editor.option == "select" then
			if key >= "1" and key <= "3" then                  world_no = 1
			elseif key >= "4" and key <= "6" then              world_no = 2
			elseif key >= "7" and key <= "9" then              world_no = 3
			elseif key == "a" or key == "b" or key == "c" then world_no = 4
			elseif key == "d" or key == "e" or key == "f" then world_no = 5
			elseif key == "g" or key == "h" or key == "i" then world_no = 6
			elseif key == "j" or key == "k" then               world_no = 7
			end

			if key >= "1" and key <= "9" then
				level_no = ((key - 1) % 3) + 1

				editor.openLevel(world_no, level_no)

			--TODO: We check if string length of keycode is 1 because we then exclude keys such as "esc" that way. Maybe there is a cleaner way to do this.
			elseif string.len(key) == 1 and key >= "a" and key <= "k" then
				level_no = ((string.byte(key) - 97) % 3) + 1

				editor.openLevel(world_no, level_no)

			elseif key == "q" then
				editor.quitToDebugMenu()
			end

		elseif editor.option == "edit" then
			if key == "l" then
				editor.loadLevel(world.current, world.level, world.area)

			elseif key == "v" then
				editor.saveLevel(world.current, world.level)

			elseif key == "p" then
				editor.playLevel()

			elseif key == "[" then
				editor.goToPreviousArea()

			elseif key == "]" then
				editor.goToNextArea()

			elseif key == "tab" then
				editor.changeMode()

			elseif key == "c" then
				editor.changeView()

			elseif key == "q" then
				editor.quit()

			elseif key == "left" then
				if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
					editor.moveView(-16, 0)
				else
					if editor.mode == "normal" then
						editor.moveCursor(-16, 0)

					elseif editor.mode == "start" then
						local x

						if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
							x = -16
						else
							x = -1
						end

						editor.moveStartingPosition(x, 0)
					end
				end

			elseif key == "right" then
				if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
					editor.moveView(16, 0)
				else
					if editor.mode == "normal" then
						editor.moveCursor(16, 0)

					elseif editor.mode == "start" then
						local x

						if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
							x = 16
						else
							x = 1
						end

						editor.moveStartingPosition(x, 0)
					end
				end

			elseif key == "up" then
				if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
					editor.moveView(0, -16)
				else
					if editor.mode == "normal" then
						editor.moveCursor(0, -16)

					elseif editor.mode == "start" then
						local y

						if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
							y = -16
						else
							y = -1
						end

						editor.moveStartingPosition(0, y)
					end
				end

			elseif key == "down" then
				if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
					editor.moveView(0, 16)
				else
					if editor.mode == "normal" then
						editor.moveCursor(0, 16)

					elseif editor.mode == "start" then
						local y

						if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
							y = 16
						else
							y = 1
						end

						editor.moveStartingPosition(0, y)
					end
				end
			end

			if editor.mode == "normal" then
				if key == "t" then
					editor.updateType()

				elseif key == "b" then
					editor.updateBackground()

				elseif key == "m" then
					editor.updateMusic()

				elseif key == "kp4" then
					editor.shrinkAreaWidth()

				elseif key == "kp6" then
					editor.scratchAreaWidth()

				elseif key == "kp8" then
					editor.shrinkAreaHeight()

				elseif key == "kp2" then
					editor.scratchAreaHeight()

				-- Decrease tile ID by 16
				elseif key == "w" then
					editor.changeTile(-16)

				-- Increase tile ID by 16
				elseif key == "s" then
					editor.changeTile(16)

				-- Decrease tile ID by 1
				elseif key == "a" then
					editor.changeTile(-1)

				-- Increase tile ID by 1
				elseif key == "d" then
					editor.changeTile(1)

				-- Remove tile
				elseif key == "z" then
					editor.placeTile(0)

				elseif key == "x" then
					editor.placeTile(editor.tile)
				end
			end
		end

	elseif state.name == "debug" then
	-- Debug screen
		if key == "f" then
		-- Show FPS counter or not
			debugging.fps = not debugging.fps

		elseif key == "r" then
		-- Show frames counter or not
			debugging.frames = not debugging.frames

		-- Mute music or not
		elseif key == "m" then
			debugging.mute = not debugging.mute

		elseif key == "l" then
		-- Go to level editor
			state.name = "level_editor"
			state.timer = 0

			debugging.frames = false
			editor.option = "select"

			graphics.setBackgroundColor("black")
		end
	end
end

return input