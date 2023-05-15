local input = {}

function input.checkForMenu(key)
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
end

function input.checkForEditor(key)
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
		if love.keyboard.isDown("lctrl", "rctrl") then
			editor.view.moveByTile(-16, 0)
		else
			if editor.mode == "normal" then
				editor.moveCursor(-16, 0)

			elseif editor.mode == "start" then
				local x

				if love.keyboard.isDown("lshift", "rshift") then
					x = -16
				else
					x = -1
				end

				editor.moveStartingPosition(x, 0)
			end
		end

	elseif key == "right" then
		if love.keyboard.isDown("lctrl", "rctrl") then
			editor.view.moveByTile(16, 0)
		else
			if editor.mode == "normal" then
				editor.moveCursor(16, 0)

			elseif editor.mode == "start" then
				local x

				if love.keyboard.isDown("lshift", "rshift") then
					x = 16
				else
					x = 1
				end

				editor.moveStartingPosition(x, 0)
			end
		end

	elseif key == "up" then
		if love.keyboard.isDown("lctrl", "rctrl") then
			editor.view.moveByTile(0, -16)
		else
			if editor.mode == "normal" then
				editor.moveCursor(0, -16)

			elseif editor.mode == "start" then
				local y

				if love.keyboard.isDown("lshift", "rshift") then
					y = -16
				else
					y = -1
				end

				editor.moveStartingPosition(0, y)
			end
		end

	elseif key == "down" then
		if love.keyboard.isDown("lctrl", "rctrl") then
			editor.view.moveByTile(0, 16)
		else
			if editor.mode == "normal" then
				editor.moveCursor(0, 16)

			elseif editor.mode == "start" then
				local y

				if love.keyboard.isDown("lshift", "rshift") then
					y = 16
				else
					y = 1
				end

				editor.moveStartingPosition(0, y)
			end
		end

	elseif key == "pageup" then
		if love.keyboard.isDown("lctrl", "rctrl") then
			editor.view.moveByScreen(-1, 0)
		else
			editor.view.moveByScreen(0, -1)
		end

	elseif key == "pagedown" then
		if love.keyboard.isDown("lctrl", "rctrl") then
			editor.view.moveByScreen(1, 0)
		else
			editor.view.moveByScreen(0, 1)
		end

	elseif key == "home" then
		if love.keyboard.isDown("lctrl", "rctrl") then
			editor.view.moveToHorizontalStart()
		else
			editor.view.moveToVerticalStart()
		end

	elseif key == "end" then
		if love.keyboard.isDown("lctrl", "rctrl") then
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

		elseif not love.keyboard.isDown("lctrl", "rctrl") and key == "m" then
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

return input