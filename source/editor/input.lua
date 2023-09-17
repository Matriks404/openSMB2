local input = {}

--TODO: This is temporary, later we want to have clickable level buttons on the bottom screen, maybe also selectable with d-pad as well.
function input.checkForMenu(joystick, button)
	local world_no, level_no

	-- For levels 1-1 to 4-1.
	if joystick:isGamepadDown("start") then
		if button == "dpup" then       world_no, level_no = 1, 1
		elseif button == "dpdown" then world_no, level_no = 1, 2
		elseif button == "dpleft" then world_no, level_no = 1, 3
		elseif button == "dpright" then world_no, level_no = 2, 1
		elseif button == "a" then world_no, level_no = 2, 2
		elseif button == "b" then world_no, level_no = 2, 3
		elseif button == "x" then world_no, level_no = 3, 1
		elseif button == "y" then world_no, level_no = 3, 2
		elseif button == "leftshoulder" then world_no, level_no = 3, 3
		elseif button == "rightshoulder" then world_no, level_no = 4, 1
		end

		editor.openLevel(world_no, level_no)

	-- For levels 4-2 to 7-2.
	elseif joystick:isGamepadDown("back") then
		if button == "dpup" then       world_no, level_no = 4, 2
		elseif button == "dpdown" then world_no, level_no = 4, 3
		elseif button == "dpleft" then world_no, level_no = 5, 1
		elseif button == "dpright" then world_no, level_no = 5, 2
		elseif button == "a" then world_no, level_no = 5, 3
		elseif button == "b" then world_no, level_no = 6, 1
		elseif button == "x" then world_no, level_no = 6, 2
		elseif button == "y" then world_no, level_no = 6, 3
		elseif button == "leftshoulder" then world_no, level_no = 7, 1
		elseif button == "rightshoulder" then world_no, level_no = 7, 2
		end

		editor.openLevel(world_no, level_no)

	elseif button == "b" then
		editor.quitToTitleScreen()
	end
end

--TODO: This should be simplified with some general controls overhaul (that I will probably do with custom controls support).
--TODO: Change this controls later with some stuff on the bottom screen along with instructions regarding the rest of buttons.
function input.checkForEditor(joystick, button)
	if button == "dpup" then
		if joystick:isGamepadDown("a") then
			if editor.mode == "normal" then
				editor.changeTile(-16)

			elseif editor.mode == "start" then
				editor.moveStartingPosition(0, -16)
			end

		elseif joystick:isGamepadDown("b") then
			if editor.mode == "normal" then
				editor.shrinkAreaHeight()
			end

		elseif joystick:isGamepadDown("leftshoulder") then
			editor.changeMode()

		elseif joystick:isGamepadDown("rightshoulder") then
			editor.view.moveByScreen(0, -1)

		elseif joystick:isGamepadDown("start") then
			editor.playLevel()

		elseif joystick:isGamepadDown("back") then
			if editor.mode == "normal" then
				editor.updateType()
			end

		else
			if editor.mode == "normal" then
				editor.moveCursor(0, -16)

			elseif editor.mode == "start" then
				editor.moveStartingPosition(0, -1)
			end
		end

		return

	elseif button == "dpdown" then
		if joystick:isGamepadDown("a") then
			if editor.mode == "normal" then
				editor.changeTile(16)

			elseif editor.mode == "start" then
				editor.moveStartingPosition(0, 16)
			end

		elseif joystick:isGamepadDown("b") then
			if editor.mode == "normal" then
				editor.scratchAreaHeight()
			end

		elseif joystick:isGamepadDown("leftshoulder") then
			editor.changeView()

		elseif joystick:isGamepadDown("rightshoulder") then
			editor.view.moveByScreen(0, 1)

		elseif joystick:isGamepadDown("start") then
			editor.quit()

		elseif joystick:isGamepadDown("back") then
			if editor.mode == "normal" then
				editor.resizeAreaToValidSize()
			end

		else
			if editor.mode == "normal" then
				editor.moveCursor(0, 16)

			elseif editor.mode == "start" then
				editor.moveStartingPosition(0, 1)
			end
		end

		return

	elseif button == "dpleft" then
		if joystick:isGamepadDown("a") then
			if editor.mode == "normal" then
				editor.changeTile(-1)

			elseif editor.mode == "start" then
				editor.moveStartingPosition(-16, 0)
			end

		elseif joystick:isGamepadDown("b") then
			if editor.mode == "normal" then
				editor.shrinkAreaWidth()
			end

		elseif joystick:isGamepadDown("leftshoulder") then
			if editor.mode == "normal" then
				editor.removeArea()
			end

		elseif joystick:isGamepadDown("rightshoulder") then
			editor.view.moveByScreen(-1, 0)

		elseif joystick:isGamepadDown("start") then
			editor.loadLevel()

		elseif joystick:isGamepadDown("back") then
			if editor.mode == "normal" then
				editor.updateBackground()
			end

		else
			if editor.mode == "normal" then
				editor.moveCursor(-16, 0)

			elseif editor.mode == "start" then
				editor.moveStartingPosition(-1, 0)
			end
		end

		return

	elseif button == "dpright" then
		if joystick:isGamepadDown("a") then
			if editor.mode == "normal" then
				editor.changeTile(1)

			elseif editor.mode == "start" then
				editor.moveStartingPosition(16, 0)
			end

		elseif joystick:isGamepadDown("b") then
			if editor.mode == "normal" then
				editor.scratchAreaWidth()
			end

		elseif joystick:isGamepadDown("leftshoulder") then
			if editor.mode == "normal" then
				editor.addArea()
			end

		elseif joystick:isGamepadDown("rightshoulder") then
			editor.view.moveByScreen(1, 0)

		elseif joystick:isGamepadDown("start") then
			editor.saveLevel()

		elseif joystick:isGamepadDown("back") then
			if editor.mode == "normal" then
				editor.updateMusic()
			end

		else
			if editor.mode == "normal" then
				editor.moveCursor(16, 0)

			elseif editor.mode == "start" then
				editor.moveStartingPosition(1, 0)
			end
		end

		return
	end

	-- Controls for all editor modes
	if button == "leftshoulder" then
		editor.goToPreviousArea()

		return

	elseif button == "rightshoulder" then
		editor.goToNextArea()

		return
	end

	-- Controls for specific modes
	if editor.mode == "normal" then
		if button == "a" then
			editor.placeTile(editor.tile)

		elseif button == "b" then
			editor.removeTile()
		end
	end
end

return input