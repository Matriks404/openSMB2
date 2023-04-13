local launcher = {}

launcher.selection = 1

launcher.games = {}

function launcher.load()
	launcher.loadFont()

	launcher.loadGameList()

	state.name = "launcher"
end

function launcher.loadFont()
	directory = "resources/images/font/"

	font.loadSymbols(directory, "launcher")
end

function launcher.loadGameList()
	local directory = "games/"

	local dirs = love.filesystem.getDirectoryItems(directory)

	for i, dir_name in pairs(dirs) do
		local game_directory = directory..dir_name
		local info = love.filesystem.getInfo(game_directory)

		if info.type == "directory" and utils.stringEndsWith(dir_name, "pack") then
			local settings_file = love.filesystem.read(game_directory.."/settings.lua")
			local settings = TSerial.unpack(settings_file)

			local default_levelpack = settings[3]

			-- Let's check if default level directory exists.
			local default_lp_directory = game_directory.."/levelpacks/"..default_levelpack

			if love.filesystem.getInfo(default_lp_directory) then
				local array = {}

				array.directory = game_directory
				array.name = settings[1]
				array.version = settings[2]
				array.default_levelpack = default_levelpack
				array.font1 = settings[4][1]
				array.font2 = settings[4][2]
				array.title_text = settings[5]

				table.insert(launcher.games, array)
			end
		end
	end
end

function launcher.goToPrevious()
	if launcher.selection > 1 then
		launcher.selection = launcher.selection - 1
	else
		launcher.selection = #launcher.games
	end
end

function launcher.goToNext()
	if launcher.selection < #launcher.games then
		launcher.selection = launcher.selection + 1
	else
		launcher.selection = 1
	end
end

function launcher.runGame(id)
	game.load(id)
end

function launcher.draw()
	graphics.drawText("openSMB2 Launcher", 16, 16, "launcher")

	if next(launcher.games) == nil then
		graphics.drawText("There are no games installed", 8, 48, "launcher")
		graphics.drawText("in your user directory.", 8, 60, "launcher")

		graphics.drawText("Check instructions here:", 8, 92, "launcher")
		graphics.drawText("github.com/Matriks404/openSMB2", 8, 108, "launcher")
		graphics.drawText("to get games installed.", 8, 124, "launcher")

		return
	end

	local x, y = 24, 48

	for key in pairs(launcher.games) do
		game_name = launcher.games[key].name

		graphics.drawText(game_name, x, y, "launcher")

		y = y + 16
	end

	graphics.drawText(">", 8, ((launcher.selection - 1) * 16) + 48, "launcher")
end

return launcher