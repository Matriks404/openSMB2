local story = {}

story.lines = 0
story.page = 1

function story.load(directory)
	local path = directory.."story.lua"

	if not love.filesystem.getInfo(path) then
		print("Info: No 'story.lua' file.")

		return
	end

	local file = love.filesystem.read(path)
	local success, contents = pcall(TSerial.unpack, file)

	if not success then
		print("Warning: The 'story.lua' file is invalid! Title screen won't play intro story.")

		return
	end

	for i = 1, #contents do
		story[i] = contents[i]
	end
end

return story