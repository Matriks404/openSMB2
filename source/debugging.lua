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
	local font = debugging.getFont()

	graphics.drawText("MUTED", 215, 231, font)
end

function debugging.drawCounter(n, y, add)
	local font = debugging.getFont()
	local str = tostring(n)

	if add then
		str = str..add
	end

	local x = graphics.width - 8
	graphics.drawTextAlignedToRight(string.format("%d%s", n, add or ""), x, y, font)
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
	local font = debugging.getFont()

	if debugging.info then
		graphics.drawText("V"..app.version, 2, 2, font)
	end

	if debugging.enabled then
		graphics.drawText("DEBUG", 2, 12, font)

		if state.name == "gameplay" then
			graphics.drawText(" -CHAR-", 2, 28, font)
			graphics.drawText("X     "..character.pos_x, 2, 36, font)
			graphics.drawText("Y     "..character.pos_y, 2, 44, font)
			graphics.drawText("SUBX  "..character.subpos_x, 2, 52, font)
			graphics.drawText("SPEED "..character.speed, 2, 60, font)
			graphics.drawText("ACCEL "..character.accel, 2, 68, font)
		end

		if debugging.pause then
			graphics.drawText("PAUSE", 2, 231, font)
		end
	end
end

function debugging.drawTopRightGraphicsStats()
	local font = debugging.getFont()

	if not debugging.enabled then
		return
	end

	local stats = love.graphics.getStats()
	local x = graphics.width - 8

	graphics.drawTextAlignedToRight("-GRAPHICS- ", x, 32, font)
	graphics.drawTextAlignedToRight("DRAWS "..tostring(stats.drawcalls), x, 42, font)
	--graphics.drawTextAlignedToRight("CANVASSWITCHES "..tostring(stats.canvasswitches), x, 52, font)
	graphics.drawTextAlignedToRight("TEXMEM "..tostring(stats.texturememory), x, 52, font)
	graphics.drawTextAlignedToRight("IMAGES "..tostring(stats.images), x, 62, font)
	--graphics.drawTextAlignedToRight("CANVASES "..tostring(stats.canvases), x, 82, font)
	--graphics.drawTextAlignedToRight("FONTS "..tostring(stats.fonts), x, 92, font)
end

function debugging.drawInfo()
	if app.muted then
		debugging.drawMutedText()
	end

	debugging.drawCounters()

	if state.name ~= "level_editor" then
		debugging.drawTopLeftInfo()
	end

	debugging.drawTopRightGraphicsStats()
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

				music.stop()
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