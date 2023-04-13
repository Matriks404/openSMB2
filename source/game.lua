local game = {}

function game.load(id)
	game.directory = launcher.games[id].directory
	game.name = launcher.games[id].name
	game.version = launcher.games[id].version
	game.levelpack = launcher.games[id].default_levelpack
	game.font1 = launcher.games[id].font1
	game.font2 = launcher.games[id].font2
	game.title_text = launcher.games[id].title_text

	love.window.setTitle(app.title.." - "..game.name)

	resources.load(game.directory)
	graphics.loadWorldImages()

	state.name = "title"

	music.init()

	music.play("title")

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