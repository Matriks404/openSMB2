local story = {}

story.lines = 0
story.page = 1

function story.load(directory)
	local path = directory.."story.lua"

	if love.filesystem.getInfo(path) then
		local file = love.filesystem.read(path)
		local contents = TSerial.unpack(file)

		for i = 1, #contents do
			story[i] = contents[i]
		end
	end
end

return story