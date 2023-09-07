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

--TODO: Most stuff is not implemented due to not having touchscreen controls yet.
function input.checkForEditor(joystick, button)
	if button == "leftshoulder" then
		editor.goToNextArea()

	elseif button == "rightshoulder" then
		editor.changeMode()

	--TODO: Readd these with button combinations because entering proper leve editor with button combination starting with START or SELECT for some reason processes input once again here.
	--elseif button == "start" then
	--	editor.playLevel()

	--elseif button == "back" then
	--	editor.saveLevel()
	--	editor.quit()

	elseif button == "dpleft" then
		if editor.mode == "normal" then
			editor.moveCursor(-16, 0)
		elseif editor.mode == "start" then
			editor.moveStartingPosition(-1, 0)
		end

	elseif button == "dpright" then
		if editor.mode == "normal" then
			editor.moveCursor(16, 0)
		elseif editor.mode == "start" then
			editor.moveStartingPosition(1, 0)
		end

	elseif button == "dpup" then
		if editor.mode == "normal" then
			editor.moveCursor(0, -16)
		elseif editor.mode == "start" then
			editor.moveStartingPosition(0, -1)
		end

	elseif button == "dpdown" then
		if editor.mode == "normal" then
			editor.moveCursor(0, 16)
		elseif editor.mode == "start" then
			editor.moveStartingPosition(0, 1)
		end
	end

	if editor.mode == "normal" then
		if button == "a" then
			editor.placeTile(editor.tile)

		elseif button == "b" then
			editor.removeTile()

		elseif button == "x" then
			editor.changeTile(1)

		elseif button == "y" then
			editor.changeTile(-1)
		end
	end
end

return input