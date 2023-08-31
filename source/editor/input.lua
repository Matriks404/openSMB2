local input = {}

function input.checkForMenu(button)
	local world_no, level_no

	--[[
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

	]]--

	--TODO: This is a temporary solution, just use the touchpad later.
	world_no = 1
	level_no = 1

	if button == "a" or button == "start" then
		editor.openLevel(world_no, level_no)

	elseif button == "b" then
		editor.quitToTitleScreen()
	end
end

--TODO: Most stuff is not implemented due to not having touchscreen controls yet. Also I don't know how to implement button combinations, this may be helpfull as well.
function input.checkForEditor(button)
	if button == "leftshoulder" then
		editor.goToNextArea()

	elseif button == "rightshoulder" then
		editor.changeMode()

	elseif button == "start" then
		editor.playLevel()

	elseif button == "back" then
		editor.saveLevel()
		editor.quit()

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