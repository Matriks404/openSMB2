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

	state.name = "title"
	state.timer = 0

	game_resources.music.play("title")
	graphics.setBackgroundColor("blue")
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