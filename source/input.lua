local input = {}
-- TODO: Refactor this? We should probably move game-related code to game.lua, although not sure.

function input.checkPressed(key)
	debugging.checkInputPressed(key)

	if state.name == "gameplay" then
		if key == "left" then
			character.has_controlled_movement = true
			character.side = -1

		elseif key == "right" then
			character.has_controlled_movement = true
			character.side = 1
		end

		if key == "z" then
			character.is_running = true
		end
	end
end

function input.checkReleased(key)
	if key == "escape" then
		love.event.quit()

	elseif (love.keyboard.isDown("lalt", "ralt") and key == "return") or key == "f11" then
		window.switchFullscreen()

	elseif key == "-" and not love.keyboard.isDown("lctrl", "rctrl") then
		graphics.scaleDown()

	elseif key == "=" and not love.keyboard.isDown("lctrl", "rctrl") then
		graphics.scaleUp()

	elseif love.keyboard.isDown("lctrl", "rctrl") and key == "m" then
		app.switchMuteState()
	end

	debugging.checkInputReleased(key)

	-- Return prematurely if the application is paused. We don't need to check input anymore.
	if debugging.pause then
		return
	end

	if state.name == "launcher" then
		if key == "up" then
			launcher.goToPrevious()
		elseif key == "down" or key == "a" then
			launcher.goToNext()
		elseif key == "x" or key == "s" then
			launcher.runGame(launcher.selection)
		end

		return

	elseif state.name == "title" then
		if key == "s" then
			state.set("character_select")

			state.transitionClear()
			game.reset()

		elseif love.keyboard.isDown("lctrl", "rctrl") and key == "l" then
			state.set("level_editor_menu")
		end

		return

	elseif state.name == "character_select" then
		-- Select character on the left
		if key == "left" and state.transition_timer == 0 then
			state.cursor = (state.cursor > 0 and state.cursor - 1) or 3

			if game_resources.sound.pickup then
				sound.play("pickup")
			end

		-- Select character on the right
		elseif (key == "right" or key == "a") and state.transition_timer == 0 then
			state.cursor = (state.cursor < 3 and state.cursor + 1) or 0

			if game_resources.sound.pickup then
				sound.play("pickup")
			end

		-- Choose character and enable transition which will go to levelbook after some time
		elseif (key == "x" or key == "s") and state.transition_timer == 0 then
			state.transition = true

			if game_resources.sound.pickup then
				sound.play("pickup")
			end
		end

		return

	elseif state.name == "gameplay" then
		if key == "s" and state.timer > 146 and state.transition_timer == 0 then
			state.backup_timer = state.timer

			state.set("pause")

		else
			if key == "left" or key == "right" then
				character.has_controlled_movement = false
			end

			if key == "z" then
				character.is_running = false
			end
		end

		return

	elseif state.name == "pause" then
		if key == "s" then
			state.set("gameplay")
			state.timer = state.backup_timer
			state.transition_timer = 0

			-- This is a bit hacky, but whatever.
			graphics.setBackgroundColor(world.current_area.background)
		end

		return

	elseif state.name == "game_over" then
		-- Select option
		if key == "up" or key == "down" or key == "a" and character.continues > 0 then
			state.cursor = (state.cursor == 0 and 1) or 0
		end

		if key == "x" or key == "s" then
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

		return

	elseif state.name == "level_editor_menu" then
		editor.input.checkForMenu(key)

		return

	elseif state.name == "level_editor" then
		editor.input.checkForEditor(key)

		return
	end
end

return input