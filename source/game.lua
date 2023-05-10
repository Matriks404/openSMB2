local game = {}

function game.load(id)
	local gamepack = launcher.gamepacks[id]

	game.directory = gamepack.directory
	game.name = gamepack.name
	game.version = gamepack.version
	--game.levelpack = gamepack.default_levelpack --TODO: Implement levelpacks.
	game.font1 = gamepack.font1
	game.font2 = gamepack.font2
	game.title_text = gamepack.title_text

	love.window.setTitle(app.title.." - "..game.name)

	game_resources.load(game.directory)
	graphics.loadWorldImages()

	editor.loadImages()

	game.setupStates()
	state.set("title")
end

function game.reset()
	world.reset()
	character.reset()
end

function game.setupStates()
	state.setupState("title", "blue", game.font1, "title")
	state.setupState("intro", "blue", game.font1, "title")
	state.setupState("character_select", "black", game.font1, "character_select")
	state.setupState("level_intro", "black", game.font2, nil)
	state.setupState("gameplay", "LEVEL_SPECIFIC", game.font1, "LEVEL_SPECIFIC")
	state.setupState("pause", "black", game.font2, "LEVEL_SPECIFIC")
	state.setupState("death", "black", game.font2, nil)
	state.setupState("game_over", "black", game.font1, nil)
	state.setupState("level_editor", "black", game.font1, nil)
end

function game.getRemainingLives(lives)
	local str, letter

	local lives = lives - 1

	if lives < 10 then
		str = " "..tostring(lives)

	elseif lives < 100 then
		str = tostring(lives)

	elseif lives < 255 then
		local tens_digit = math.floor((lives - 100) / 10)
		local letter = string.char(tens_digit + 65)

		local digit = tostring((lives) % 10)

		str = letter..digit
	end

	return str
end

return game