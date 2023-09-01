local input = {}
-- TODO: Refactor this? We should probably move game-related code to game.lua, although not sure.

function input.checkPressed(button)
	if state.name == "gameplay" then
		if button == "dpleft" then
			character.has_controlled_movement = true
			character.side = -1

		elseif button == "dpright" then
			character.has_controlled_movement = true
			character.side = 1
		end

		if button == "b" then
			character.is_running = true
		end
	end
end

function input.checkReleased(button)
	--[[
	if (love.keyboard.isDown("lalt", "ralt") and key == "return") or key == "f11" then
		window.updateFullscreen()

	elseif key == "-" then
		if love.keyboard.isDown("lctrl", "rctrl") then
			if state.name == "level_editor" and editor.mode == "normal" then
				editor.removeArea()
			end
		else
			graphics.scaleDown()
		end

	elseif key == "=" then
		if love.keyboard.isDown("lctrl", "rctrl") then
			if state.name == "level_editor" and editor.mode == "normal" then
				editor.addArea()
			end
		else
			graphics.scaleUp()
		end
	--]]

	if state.name ~= "level_editor" and button == "rightshoulder" then
		app.switchMuteState()
	end

	debugging.checkInput(button)

	-- Return prematurely if the application is paused. We don't need to check input anymore.
	if debugging.pause then
		return
	end

	if state.name == "launcher" then
		if button == "dpup" then
			launcher.goToPrevious()
		elseif button == "dpdown" then
			launcher.goToNext()
		elseif button == "a" or button == "start" then
			launcher.runGame(launcher.selection)
		end

		return

	elseif state.name == "title" then
		if button == "start" then
			state.set("character_select")

			state.transitionClear()
			game.reset()

		elseif button == "y" then
			state.set("level_editor_menu")
		end

		return

	elseif state.name == "character_select" then
		-- Select character on the left
		if button == "dpleft" and state.transition_timer == 0 then
			state.cursor = (state.cursor > 0 and state.cursor - 1) or 3

			if game_resources.sound.pickup then
				game_resources.sound.play("pickup")
			end

		-- Select character on the right
		elseif button == "dpright" and state.transition_timer == 0 then
			state.cursor = (state.cursor < 3 and state.cursor + 1) or 0

			if game_resources.sound.pickup then
				game_resources.sound.play("pickup")
			end

		-- Choose character and enable transition which will go to levelbook after some time
		elseif button == "a" and state.transition_timer == 0 then
			state.transition = true

			if game_resources.sound.pickup then
				game_resources.sound.play("pickup")
			end
		end

		return

	elseif state.name == "gameplay" then
		-- Die!
		if debugging.enabled and button == "back" then
			character.dying_timer = 84

			game_resources.music.stop()

		elseif button == "start" and state.timer > 146 and state.transition_timer == 0 then
			state.backup_timer = state.timer

			state.set("pause")

		else
			if button == "dpleft" or button == "dpright" then
				character.has_controlled_movement = false
			end

			if button == "b" then
				character.is_running = false
			end
		end

		return

	elseif state.name == "pause" then
		if button == "start" then
			state.set("gameplay")
			state.timer = state.backup_timer
			state.transition_timer = 0

			-- This is a bit hacky, but whatever.
			graphics.setBackgroundColor(world.current_area.background)
		end

		return

	elseif state.name == "game_over" then
		-- Select option
		if (button == "dpup" or button == "dpdown") and character.continues > 0 then
			state.cursor = (state.cursor == 0 and 1) or 0
		end

		if button == "a" or button == "start" then
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
		editor.input.checkForMenu(button)

		return

	elseif state.name == "level_editor" then
		editor.input.checkForEditor(button)

		return
	end
end

return input