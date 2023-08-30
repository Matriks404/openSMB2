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

		if debugging.pause then
			graphics.drawText("PAUSE", 2, 22, debugging.getFont())
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

function debugging.checkInput(button)
	if state.name == "launcher" or state.name == "title" then
		if button == "back" then
			debugging.switch()

			return
		end
	end

	if debugging.enabled then
		if button == "y" then
			debugging.switchPause()
		end
	else
		if button == "leftshoulder" then
			debugging.switchInfo()
		end
	end

	if debugging.pause then
		if button == "x" then
			debugging.advanceTimer()
		end
	end
end

return debugging