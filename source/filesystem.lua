local filesystem = {}

function filesystem.setup()
	love.filesystem.setIdentity(GAME_TITLE)

	if not love.filesystem.getInfo("userlevels") then
		love.filesystem.createDirectory("userlevels")
	end
end

return filesystem