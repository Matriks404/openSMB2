local input = {}

function input.check(key)
	if key == "escape" then
		love.event.quit()

	elseif ((love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) and key == "return") or key == "f11" then
		window.updateFullscreen()

	elseif key == "-" then
		if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
			if state.name == "level_editor" and editor.option == "edit" and editor.mode == "normal" then
				editor.removeArea()
			end
		else
			graphics.scaleDown()
		end

	elseif key == "=" then
		if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
			if state.name == "level_editor" and editor.option == "edit" and editor.mode == "normal" then
				editor.addArea()
			end
		else
			graphics.scaleUp()
		end

	elseif key == "m" then
		app.switchMuteState()
	end

	if state.name ~= "level_editor" and editor.option ~= "edit" and key == "f3" then
		debugging.switchInfo()
	end

	if state.name == "launcher" then
		if key == "up" then
			launcher.goToPrevious()
		elseif key == "down" or key == "x" then
			launcher.goToNext()
		elseif key == "return" or key == "s" then
			launcher.runGame(launcher.selection)
		end

	elseif state.name == "title" or state.name == "intro" then
		if key == "s" then
			state.set("character_select")

			state.transitionClear()
			game.reset()

		elseif (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and key == "l" then
			state.set("level_editor")

			debugging.frames = false
			editor.option = "select"
		end

	elseif state.name == "character_select" then
		-- Select character on the left
		if key == "left" and state.transition_timer == 0 then
			state.cursor = (state.cursor > 0 and state.cursor - 1) or 3

			if game_resources.sound.pickup then
				game_resources.sound.play("pickup")
			end

		-- Select character on the right
		elseif key == "right" and state.transition_timer == 0 then
			state.cursor = (state.cursor < 3 and state.cursor + 1) or 0

			if game_resources.sound.pickup then
				game_resources.sound.play("pickup")
			end

		-- Choose character and enable transition which will go to levelbook after some time
		elseif key == "x" and state.transition_timer == 0 then
			state.transition = true

			if game_resources.sound.pickup then
				game_resources.sound.play("pickup")
			end
		end

	elseif state.name == "gameplay" then
		if key == "s" and state.timer > 146 and state.transition_timer == 0 then
			state.backup_timer = state.timer

			state.set("pause")
		end

		-- Die!
		if debugging.enabled and key == "d" then
			character.dying_timer = 84

			game_resources.music.stopAll()
		end

	elseif state.name == "pause" then
		if key == "s" then
			state.set("gameplay")
			state.timer = state.backup_timer
			state.transition_timer = 0
		end

	elseif state.name == "game_over" then
		-- Select option
		if key == "a" and character.continues > 0 then
			state.cursor = (state.cursor == 0 and 1) or 0
		end

		if key == "s" then
			if state.cursor == 0 then
				character.continues = character.continues - 1
				character.lives = 3
				character.energy = 2

				state.set("character_select")
			else
				state.set("title")
				state.cursor = 0
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
			elseif #key == 1 and key >= "a" and key <= "k" then
				level_no = ((string.byte(key) - 97) % 3) + 1

				editor.openLevel(world_no, level_no)

			elseif key == "q" then
				editor.quitToTitleScreen()
			end

		elseif editor.option == "edit" then
			if key == "l" then
				editor.loadLevel()

			elseif key == "v" then
				editor.saveLevel()

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
				if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
					editor.view.moveByTile(-16, 0)
				else
					if editor.mode == "normal" then
						editor.moveCursor(-16, 0)

					elseif editor.mode == "start" then
						local x

						if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
							x = -16
						else
							x = -1
						end

						editor.moveStartingPosition(x, 0)
					end
				end

			elseif key == "right" then
				if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
					editor.view.moveByTile(16, 0)
				else
					if editor.mode == "normal" then
						editor.moveCursor(16, 0)

					elseif editor.mode == "start" then
						local x

						if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
							x = 16
						else
							x = 1
						end

						editor.moveStartingPosition(x, 0)
					end
				end

			elseif key == "up" then
				if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
					editor.view.moveByTile(0, -16)
				else
					if editor.mode == "normal" then
						editor.moveCursor(0, -16)

					elseif editor.mode == "start" then
						local y

						if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
							y = -16
						else
							y = -1
						end

						editor.moveStartingPosition(0, y)
					end
				end

			elseif key == "down" then
				if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
					editor.view.moveByTile(0, 16)
				else
					if editor.mode == "normal" then
						editor.moveCursor(0, 16)

					elseif editor.mode == "start" then
						local y

						if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
							y = 16
						else
							y = 1
						end

						editor.moveStartingPosition(0, y)
					end
				end

			elseif key == "pageup" then
				if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
					editor.view.moveByScreen(-1, 0)
				else
					editor.view.moveByScreen(0, -1)
				end

			elseif key == "pagedown" then
				if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
					editor.view.moveByScreen(1, 0)
				else
					editor.view.moveByScreen(0, 1)
				end

			elseif key == "home" then
				if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
					editor.view.moveToHorizontalStart()
				else
					editor.view.moveToVerticalStart()
				end

			elseif key == "end" then
				if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
					editor.view.moveToHorizontalEnd()
				else
					editor.view.moveToVerticalEnd()
				end
			end

			if editor.mode == "normal" then
				if key == "t" then
					editor.updateType()

				elseif key == "b" then
					editor.updateBackground()

				elseif key == "m" then
					editor.updateMusic()

				elseif key == "r" then
					editor.resizeAreaToValidSize()

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

				elseif key == "x" then
					editor.placeTile(editor.tile)

				elseif key == "z" then
					editor.removeTile()
				end
			end
		end
	end

	debugging.checkInput(key)
end

return input