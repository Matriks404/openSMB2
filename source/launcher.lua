local launcher = {}

launcher.img = {}

launcher.mandatory_files = {
	"images/charselect/arrow.png",
	"images/gameplay/characters/char1.png",
	"images/gameplay/characters/char2.png",
	"images/gameplay/characters/char3.png",
	"images/gameplay/characters/char4.png"
}

launcher.selection = 1

launcher.gamepacks = {}

function launcher.load()
	launcher.loadFont()
	launcher.loadImages()

	launcher.loadGamePackList()

	state.name = "launcher"
end

function launcher.loadFont()
	directory = "resources/images/font/"

	font.loadSymbols(directory, "dogica")
end

function launcher.loadImages()
	local directory = "resources/images/launcher/"

	launcher.img["gp_good"] = resources.loadImage(directory.."gamepack_good.png")
	launcher.img["gp_bad"] = resources.loadImage(directory.."gamepack_bad.png")
end

function launcher.validGamePackResources(directory)
	for i in ipairs(launcher.mandatory_files) do
		local path = launcher.mandatory_files[i]
		local file = directory..path

		if not love.filesystem.getInfo(file) then
			print("\tError: File: '"..path.."' doesn't exist!")

			return false
		end
	end

	return true
end

function launcher.getGamePack(directory)
	print("Validity check for gamepack in '"..directory.."' directory")
	local gamepack = {}
	gamepack.valid = false

	gamepack.directory = directory

	local settings_file_path = directory.."/settings.lua"

	if not love.filesystem.getInfo(settings_file_path) then
		print("\tError: No gamepack settings file!")

		return gamepack
	end

	local settings_file = love.filesystem.read(settings_file_path)
	local success, settings = pcall(TSerial.unpack, settings_file)

	if not success then
		print("\tError: Gamepack settings file is invalid!")

		return gamepack
	end

	gamepack.name = settings["name"]

	if not gamepack.name or gamepack.name == "" then
		print("\tWarning: Gamepack name is not specified.")
	end

	gamepack.version = settings["version"]

	if not gamepack.version or gamepack.version == "" then
		print("\tWarning: Gamepack version is not specified.")
	end

	gamepack.manifest_version = settings["manifest_version"]

	if gamepack.manifest_version ~= "0" then
		print("\tError: Invalid gamepack manifest version.")

		return gamepack
	end

	gamepack.default_levelpack = settings["default_levelpack"]

	if not gamepack.default_levelpack or gamepack.default_levelpack == "" or not utils.stringEndsWith(gamepack.default_levelpack, ".lp") then
		print("\tError: Invalid default levelpack directory name!")

		return gamepack
	end

	local default_lp_directory = directory.."/levelpacks/"..gamepack.default_levelpack

	if not love.filesystem.getInfo(default_lp_directory) then
		print("\tError: Default levelpack directory: "..default_lp_directory.." doesn't exist!")

		return gamepack
	end

	gamepack.font1 = settings["fonts"][1]

	if not gamepack.font1 or gamepack.font1 == "" then
		print("\tError: Invalid primary font name!")

		return gamepack
	end

	local font1_file = directory.."/resources/images/font/"..gamepack.font1..".png"

	if not love.filesystem.getInfo(font1_file) then
		print("\tError: Primary font: "..gamepack.font1.." doesn't exist!")

		return gamepack
	end

	gamepack.font2 = settings["fonts"][2]

	if gamepack.font2 and gamepack.font2 ~= "" then
		local font2_file = directory.."/resources/images/font/"..gamepack.font2..".png"

		if not love.filesystem.getInfo(font2_file) then
			print("\tWarning: Secondary font: "..gamepack.font2.." doesn't exist! Engine will use the primary one.")
		end
	end

	gamepack.title_text = settings["title_text"]

	if not launcher.validGamePackResources(directory.."/resources/") then
		print("\tError: Invalid game pack resources!")

		return gamepack
	end

	gamepack.valid = true
	return gamepack
end

function launcher.addGamePack(directory)
	local gamepack = launcher.getGamePack(directory)

	table.insert(launcher.gamepacks, gamepack)
end

function launcher.loadGamePackList()
	local directory = "games/"

	local dirs = love.filesystem.getDirectoryItems(directory)

	for i, dir_name in pairs(dirs) do
		if utils.stringEndsWith(dir_name, ".pack") then
			local game_directory = directory..dir_name
			local info = love.filesystem.getInfo(game_directory)

			if info.type == "directory" then
				launcher.addGamePack(game_directory)
			end
		end
	end
end

function launcher.goToPrevious()
	if launcher.selection > 1 then
		launcher.selection = launcher.selection - 1
	else
		launcher.selection = #launcher.gamepacks
	end
end

function launcher.goToNext()
	if launcher.selection < #launcher.gamepacks then
		launcher.selection = launcher.selection + 1
	else
		launcher.selection = 1
	end
end

function launcher.runGame(id)
	if launcher.gamepacks[id].valid then
		game.load(id)
	else
		love.window.showMessageBox("Error", "Selected gamepack is not valid! Check the console for details.")
	end
end

function launcher.draw()
	graphics.drawText("openSMB2 Launcher", 16, 16, "dogica")

	if next(launcher.gamepacks) == nil then
		graphics.drawText("There are no games installed", 8, 48, "dogica")
		graphics.drawText("in your user directory.", 8, 60, "dogica")

		graphics.drawText("Check instructions here:", 8, 92, "dogica")
		graphics.drawText("github.com/Matriks404/openSMB2", 8, 108, "dogica")
		graphics.drawText("to get games installed.", 8, 124, "dogica")

		return
	end

	graphics.drawText(">", 8, ((launcher.selection - 1) * 16) + 48, "dogica")

	local x, y = 24, 48

	for key in pairs(launcher.gamepacks) do
		local game_name = launcher.gamepacks[key].name

		if not game_name or game_name == "" then
			game_name = "Unknown"
		elseif #game_name > 24 then
			game_name = string.sub(game_name, 1, 21).."..."
		end

		graphics.drawText(game_name, x, y, "dogica")

		local valid = launcher.gamepacks[key].valid
		local img = (valid and launcher.img["gp_good"]) or launcher.img["gp_bad"]

		love.graphics.draw(img, x + 200, y)

		y = y + 16
	end

end

return launcher