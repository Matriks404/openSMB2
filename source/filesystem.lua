local filesystem = {}

function filesystem.setup()
	love.filesystem.setIdentity(app.title)

	if not love.filesystem.getInfo("games") then
		love.filesystem.createDirectory("games")
	end
end

return filesystem