local debugging = {}

debugging.enabled = false
debugging.info = false
debugging.fps = false
debugging.frames = true

function debugging.switch()
	debugging.enabled = not debugging.enabled
end

function debugging.switchInfo()
	debugging.info = not debugging.info
	debugging.fps = debugging.info
end

function debugging.drawMutedText()
	graphics.drawText("MUTED", 215, 231)
end

function debugging.drawCounter(n, y, add)
	local str = tostring(n)

	if add then
		str = str..add
	end

	local x = (graphics.width - string.len(str) * 8) - 1

	graphics.drawText(string.format("%02d%s", n, add or ""), x, y)
end

function debugging.drawCounters()
	if debugging.fps then
		debugging.drawCounter(love.timer.getFPS(), 2, " FPS")
	end

	if debugging.info then
		if debugging.frames then
			debugging.drawCounter(state.timer, 12)
		end
	end
end

function debugging.drawVersionText()
	if debugging.info then
		graphics.drawText("V"..app.getVersion(), 2, 2)
	end
end

function debugging.drawInfo()
	if app.muted then
		debugging.drawMutedText()
	end

	debugging.drawCounters()
	debugging.drawVersionText()

end

function debugging.checkInput(key)
	if key == "f" then
		if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
			if debugging.info then
				debugging.frames = not debugging.frames
			end
		else
			debugging.fps = not debugging.fps
		end
	end
end

return debugging