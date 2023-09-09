local launcher = {}

launcher.img = {}

launcher.mandatory_files = {
	"images/indicator.png",
	"images/tilemap.png",
	"images/charselect/arrow.png",
	"images/gameplay/characters/char1.png",
	"images/gameplay/characters/char2.png",
	"images/gameplay/characters/char3.png",
	"images/gameplay/characters/char4.png"
}

launcher.selection = 1

launcher.gamepacks = {}

function launcher.load()
	launcher.loadFonts()
	launcher.loadImages()

	launcher.loadGamePackList()

	launcher.setupStates()
	state.set("launcher")
end

function launcher.loadFonts()
	directory = "resources/images/font/"

	launcher.font_normal = "dogica"
	launcher.font_bold = "dogica_bold"

	font.loadSymbols(directory, launcher.font_normal)
	font.loadSymbols(directory, launcher.font_bold)

end

function launcher.loadImages()
	local directory = "resources/images/launcher/"

	launcher.img.gp_good = resources.loadImage(directory.."gamepack_good.png")
	launcher.img.gp_bad = resources.loadImage(directory.."gamepack_bad.png")
end

function launcher.setupStates()
	state.setupState("launcher", "black", launcher.font_bold, nil)
end

function launcher.validGamePackResources(directory)
	for i in ipairs(launcher.mandatory_files) do
		local path = launcher.mandatory_files[i]
		local file = directory..path

		if not love.filesystem.getInfo(file) then
			print("\tError: File '"..path.."' doesn't exist!")

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

	gamepack.name = settings.name

	if not gamepack.name or gamepack.name == "" then
		print("\tWarning: Gamepack name is not specified.")
	end

	gamepack.version = settings.version

	if not gamepack.version or gamepack.version == "" then
		print("\tWarning: Gamepack version is not specified.")
	end

	gamepack.manifest_version = settings.manifest_version

	if gamepack.manifest_version ~= "0" then
		print("\tError: Invalid gamepack manifest version.")

		return gamepack
	end

	--TODO: Implement levelpacks.
	--[[
	gamepack.default_levelpack = settings.default_levelpack

	if not gamepack.default_levelpack or gamepack.default_levelpack == "" or not utils.stringEndsWith(gamepack.default_levelpack, ".lp") then
		print("\tError: Invalid default levelpack directory name!")

		return gamepack
	end

	local default_lp_directory = directory.."/levelpacks/"..gamepack.default_levelpack

	if not love.filesystem.getInfo(default_lp_directory) then
		print("\tError: Default levelpack directory: "..default_lp_directory.." doesn't exist!")

		return gamepack
	end

	]]--

	gamepack.font1 = settings.fonts.primary

	if not gamepack.font1 or gamepack.font1 == "" then
		print("\tError: Invalid primary font name!")

		return gamepack
	end

	local font1_file = directory.."/resources/images/font/"..gamepack.font1..".png"

	if not love.filesystem.getInfo(font1_file) then
		print("\tError: Primary font: "..gamepack.font1.." doesn't exist!")

		return gamepack
	end

	gamepack.font2 = settings.fonts.secondary

	if gamepack.font2 and gamepack.font2 ~= "" then
		local font2_file = directory.."/resources/images/font/"..gamepack.font2..".png"

		if not love.filesystem.getInfo(font2_file) then
			print("\tWarning: Secondary font: "..gamepack.font2.." doesn't exist! Engine will use the primary one.")
		end
	end

	gamepack.title_text = settings.title_text

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
	if #launcher.gamepacks >=1 then
		if launcher.gamepacks[id].valid then
			game.load(id)
		else
			love.window.showMessageBox("Error", "Selected gamepack is not valid! Check the console for details.")
		end
	end
end

function launcher.draw()
	graphics.drawText("openSMB2 Launcher", 56, 16)

	if next(launcher.gamepacks) == nil then
		graphics.drawText("There are no games installed", 8, 56)
		graphics.drawText("in your user directory.", 8, 68)

		graphics.drawText("Check instructions on", 8, 100)
		graphics.drawText("github.com/Matriks404/openSMB2", 8, 112)
		graphics.drawText("to get games installed.", 8, 124)

		return
	end

	local x, y = 24, 56

	for key in pairs(launcher.gamepacks) do
		if key == launcher.selection then
			graphics.drawText(">", 8, y)
		end

		local game_name = launcher.gamepacks[key].name

		if not game_name or game_name == "" then
			game_name = "Unknown"
		elseif #game_name > 24 then
			game_name = string.sub(game_name, 1, 21).."..."
		end

		graphics.drawText(game_name, x, y)

		local valid = launcher.gamepacks[key].valid
		local img = (valid and launcher.img.gp_good) or launcher.img.gp_bad

		love.graphics.draw(img, x + 208, y)

		local gamepack_directory_name = string.sub(launcher.gamepacks[key].directory, 7)
		local gamepack_version = launcher.gamepacks[key].version

		local bottom_string

		if #gamepack_directory_name + #gamepack_version >= 21 then
			bottom_string = string.sub(gamepack_directory_name, 1, 14).."... (v"..gamepack_version..")"
		else
			bottom_string = gamepack_directory_name.." (v"..gamepack_version..")"
		end

		graphics.drawText(bottom_string, x, y + 12, launcher.font_normal)

		y = y + 32
	end

end

return launcher