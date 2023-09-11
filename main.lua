-- External libraries
TSerial = require "source/external/TSerial"

-- Modules
app = require "source/app"
character = require "source/character"
debugging = require "source/debugging"
editor = require "source/editor/main"
filesystem = require "source/filesystem"
game = require "source/game"
game_resources = require "source/game_resources"
graphics = require "source/graphics"
input = require "source/input"
music = require "source/music"
launcher = require "source/launcher"
resources = require "source/resources"
sound = require "source/sound"
state = require "source/state"
title = require "source/title"
window = require "source/window"
world = require "source/world"

-- Love2D callbacks
function love.load()
	app.setup()
end

function love.update(dt)
	app.update(dt)
end

function love.gamepadpressed(joystick, button)
	input.checkPressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
	input.checkReleased(joystick, button)
end

function love.draw(screen)
	if screen ~= "bottom" then
		app.draw()
	end
end