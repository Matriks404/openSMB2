local debugging = {}

debugging.enabled = false
debugging.pause = false

debugging.info = false
debugging.fps = false

function debugging.switch()
	debugging.enabled = not debugging.enabled

	if not debugging.info then
		debugging.switchInfo()
	end

	if not debugging.enabled and debugging.pause then
		debugging.switchPause()
	end
end

function debugging.switchPause()
	debugging.pause = not debugging.pause
end

function debugging.switchInfo()
	debugging.info = not debugging.info
	debugging.fps = debugging.info
end

function debugging.advanceTimer()
	state.timer = state.timer + 1

	game.update()
end

function debugging.getFont()
	return game.font1 or launcher.font_normal
end

function debugging.drawMutedText()
	graphics.drawText("MUTED", 215, 231, debugging.getFont())
end

function debugging.drawCounter(n, y, add)
	local str = tostring(n)

	if add then
		str = str..add
	end

	local str_width = string.len(str) * 8
	local x = (graphics.width - str_width) - 1

	graphics.drawText(string.format("%d%s", n, add or ""), x, y, debugging.getFont())
end

function debugging.drawCounters()
	if debugging.fps then
		debugging.drawCounter(love.timer.getFPS(), 2, " FPS")
	end

	if state.name ~= "launcher" and state.name ~= "level_editor" and debugging.info then
		debugging.drawCounter(state.timer, 12)
	end
end

function debugging.drawTopLeftInfo()
	if debugging.info then
		graphics.drawText("V"..app.getVersion(), 2, 2, debugging.getFont())
	end

	if debugging.enabled then
		graphics.drawText("DEBUG", 2, 12, debugging.getFont())

		if state.name == "gameplay" then
			graphics.drawText(" -CHAR-", 2, 28, debugging.getFont())
			graphics.drawText("X     "..character.pos_x, 2, 36)
			graphics.drawText("Y     "..character.pos_y, 2, 44)
			graphics.drawText("SUBX  "..character.subpos_x, 2, 52)
			graphics.drawText("SPEED "..character.speed, 2, 60)
			graphics.drawText("ACCEL "..character.accel, 2, 68)
		end

		if debugging.pause then
			graphics.drawText("PAUSE", 2, 231, debugging.getFont())
		end
	end
end

function debugging.drawInfo()
	if app.muted then
		debugging.drawMutedText()
	end

	if state.name ~= "level_editor" then
		debugging.drawTopLeftInfo()
	end

	debugging.drawCounters()
end

function debugging.checkInputPressed(joystick, button)
	if debugging.enabled then
		if state.name == "gameplay" and button == "dpleft" then
			character.is_ascending = true
		end
	end
end

function debugging.checkInputReleased(joystick, button)
	if (state.name == "launcher" or state.name == "title") then
		if button == "dpdown" then
			debugging.switch()

			return
		end
	end

	if debugging.enabled then
		if state.name == "gameplay" then
			if button == "dpleft" then
				character.is_ascending = false

			elseif button == "dpright" then
				character.dying_timer = 84

				game_resources.music.stop()

			end
		end

		if button == "leftshoulder" then
			debugging.switchPause()
		end
	else
		if button == "dpup" then
			debugging.switchInfo()
		end
	end

	if debugging.pause then
		if button == "rightshoulder" then
			debugging.advanceTimer()
		end
	end
end

return debugging