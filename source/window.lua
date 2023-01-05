local window = {}

window.fullscreen = false
window.resizable = false

function window.calculateMaxSize()
	local _, _, flags = love.window.getMode()
	local desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display)

	local max_width_scale = math.floor(desktop_width / graphics.width)
	local max_height_scale = math.floor(desktop_height / graphics.height)

	graphics.max_scale = math.min(max_width_scale, max_height_scale)
end

function window.update()
	love.window.setMode(graphics.width * graphics.scale, graphics.height * graphics.scale, {fullscreen = window.fullscreen, resizable = window.resizable, vsync = true})
end

function window.updateFullscreen()
	window.fullscreen = not window.fullscreen

	window.update()
end

function window.setup()
	window.calculateMaxSize()
	window.update()

	love.window.setTitle(game.full_title)
end

return window