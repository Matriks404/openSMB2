local window = {}

window.fullscreen = false
window.resizable = false
window.vsync = true

function window.setInitialScale()
	local _, _, flags = love.window.getMode()
	local desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display)

	local max_width_scale = math.floor(love.window.fromPixels(desktop_width) / graphics.width)
	local max_height_scale = math.floor(love.window.fromPixels(desktop_height) / graphics.height)

	graphics.max_scale = math.min(max_width_scale, max_height_scale)
	graphics.scale = graphics.max_scale - 1
end

function window.update()
	if window.fullscreen then
		window.fullscreenUpdate()
	else
		window.windowedUpdate()
	end
end

function window.windowedUpdate()
	local width = graphics.width * graphics.scale
	local height = graphics.height * graphics.scale

	if graphics.scale < 1 then
		graphics.scale = 0
	end

	love.window.setMode(width, height, {fullscreen = false, resizable = window.resizable, vsync = window.vsync})

	graphics.x = 0
	graphics.y = 0
end

function window.fullscreenUpdate()
	local _, _, flags = love.window.getMode()
	local desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display)

	if not flags.fullscreen then
		love.window.setMode(desktop_width, desktop_height, {fullscreen = true, vsync = window.vsync})
	end

	local rendered_width = graphics.width * graphics.scale
	local rendered_height = graphics.height * graphics.scale

	graphics.x = (desktop_width - rendered_width) / 2
	graphics.y = (desktop_height - rendered_height) / 2
end

function window.switchFullscreen()
	window.fullscreen = not window.fullscreen

	window.update()
end

function window.setup()
	window.setInitialScale()
	window.update()

	love.window.setTitle(app.title)
end

--TODO: Do something on window resize, for level editor purposes.
--[[
function window.resize()
	local width, height, _ = love.window.getMode()

	-- ...
end
]]--

return window