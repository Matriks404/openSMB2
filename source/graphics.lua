local graphics = {}

graphics.bg = {}
graphics.bg["black"] = { short_name = "BLK", r = 0, g = 0, b = 0 }
graphics.bg["light_blue"] = { short_name = "LBL", r = 0.36, g = 0.58, b = 0.99 }
graphics.bg["blue"] = { short_name = "BLU", r = 0.36, g = 0.58, b = 0.99 }

graphics.width = 256
graphics.height = 240

graphics.scale = 1
graphics.max_scale = 1

graphics.tile_size = 16

function graphics.init()
	love.graphics.setDefaultFilter("nearest")

	graphics.setBackgroundColor("blue")
end

function graphics.scaleDown()
	graphics.scale = graphics.scale - 1

	if graphics.scale < 1 then
		graphics.scale = 1
	else
		window.update()
	end
end

function graphics.scaleUp()
	graphics.scale = graphics.scale + 1

	if graphics.scale > graphics.max_scale then
		graphics.scale = graphics.max_scale
	else
		window.update()
	end
end

function graphics.setBackgroundColor(color)
	local r = graphics.bg[color].r
	local g = graphics.bg[color].g
	local b = graphics.bg[color].b

	love.graphics.setBackgroundColor(r, g, b)
end

function graphics.drawText(str, x, y, color)
	local color = color or "white"

	local real_x = 0

	for i = 0, string.len(str) - 1 do
		local pos_x = x + (i * 16)

		if real_x == 0 then
			real_x = pos_x
		end

		local code = string.byte(str, i + 1)

		local ax = (code % 32) * 16
		local ay = math.floor(code / 32) * 16

		local symbol = love.graphics.newQuad(ax, ay, 16, 16, font[color]:getWidth(), font[color]:getHeight())

		love.graphics.draw(font[color], symbol, real_x, y, 0, 0.5)

		real_x = real_x + 8
	end
end

function graphics.drawCounter(n, y, add)
	local width = 0
	local d = n

	while d > 0 do
		width = width + 1
		d = math.floor(d / 10)
	end

	local str = tostring(n)
	local x = graphics.width - (width * 8)

	if add then
		str = str..add
		x = x - (string.len(add) * 8)
	end

	graphics.drawText(str, x, y)

end

function graphics.drawTile(id, x, y)
	local ax = (id % 16) * 16
	local ay = math.floor(id / 16) * 16

	local tilemap_width = img.tilemap:getWidth()
	local tilemap_height = img.tilemap:getHeight()

	tile = love.graphics.newQuad(ax, ay, 16, 16, tilemap_width, tilemap_height)

	love.graphics.draw(img.tilemap, tile, x, y)
end

function graphics.drawLevelTiles()
	local top_y = 0
	local bottom_y = 15

	local trans_y, tile_x, tile_y, pos_x, pos_y

	if state.transition_timer > 0 then
		if state.transition_timer < 35 then
			-- During transition draw additional row of tiles
			if state.screen_y > 0 and state.screen_dir == - 1 then
			-- Draw additional row of tiles on the top
				top_y = -1
			end

			if state.screen_y <= ((world.current_area.height - 192) / graphics.tile_size / 12) and state.screen_dir == 1 then
			-- Draw additional row of tiles on the bottom
				bottom_y = 16
			end
		end

		trans_y = state.screen_dir == 1 and math.floor(state.transition_timer / 35 * 9) or (9 - math.floor(state.transition_timer / 35 * 9))
	end

    local trans_offset = (state.transition_timer / 35 * 144) % graphics.tile_size

    for i = top_y, bottom_y - 1 do
        if state.transition_timer > 0 then
			if state.screen_dir == 1 then
				tile_y = (state.screen_y * 9) + trans_y + i
				pos_y = (i * graphics.tile_size) - trans_offset
			else
				tile_y = ((state.screen_y - 1) * 9) + trans_y + i
				pos_y = (i * graphics.tile_size) + trans_offset
			end
        else
			tile_y = (state.screen_y * 9) + i
			pos_y = i * graphics.tile_size
		end

        for j = 0, 16 - 1 do
            tile_x = (state.screen_x * graphics.tile_size) + j
            pos_x = j * graphics.tile_size

            graphics.drawTile(world.current_area.tiles[tile_y][tile_x], pos_x, pos_y)
        end
    end
end

function graphics.drawCharacter()
	local offset, ax, pos_y
	pos_x = character.pos_x

	-- Calculate offset for character sprite
	if character.side == -1 then
		offset = 16

	elseif character.side == 1 then
		offset = 0
	end

	-- Calculate desired character sprite
	if character.state == "stationary" then
	-- Calculate sprite if character is walking
		if character.speed > 0 then
			if state.char_anim_timer >= 10 then
				state.char_anim_timer = 0
			end

			ax = (state.char_anim_timer >= 5 and 0) or 16

			state.char_anim_timer = state.char_anim_timer + 1
		else
			ax = 0

			state.char_anim_timer = 0
		end
	elseif character.current == "luigi" and character.state == "falling" then
	-- Calculate sprite if character is Luigi and falling
		if state.char_anim_timer >= 6 then
			state.char_anim_timer = 0
		end

		ax = (state.char_anim_timer >= 3 and 0) or 16

		if state.transition_timer == 0 then
			state.char_anim_timer = state.char_anim_timer + 1
		end
	else
		ax = 16

		state.char_anim_timer = 0
	end

	if state.screen_y == 0 then
		pos_y = character.pos_y - state.screen_y * 240
	else
		pos_y = character.pos_y - state.screen_y * 144
	end

	if state.transition_timer > 0 then
		if state.screen_dir == 1 then
			pos_y = pos_y - (state.transition_timer / 35) * 144
		else
			pos_y = pos_y + (state.transition_timer / 35) * 144
		end
	end

	local char, sprite

	-- Draw character sprite
	if character.current == "mario" then
		char = img.chars_mario

	elseif character.current == "luigi" then
		char = img.chars_luigi

	elseif character.current == "toad" then
		char = img.chars_toad

	elseif character.current == "peach" then
		char = img.chars_peach
	end

	sprite = love.graphics.newQuad(ax, 0, 16, 32, char:getWidth(), char:getHeight())
	love.graphics.draw(char, sprite, pos_x, pos_y, 0, character.side, 1, offset)

	-- Draw character sprite when it's horizontally wraping
	if character.pos_x > 256 - 16 then
		pos_x = pos_x - world.current_area.width

		love.graphics.draw(char, sprite, pos_x, pos_y, 0, character.side, 1, offset)
	end
end

function graphics.drawLevelbook()
	love.graphics.draw(img.levelbook, 25, 32)

	graphics.drawText("WORLD  "..tostring(world.current).."-"..tostring(world.level), 89, 48, "brown")

	if world.current < 7 then
		world.level_count = 3
	else
		world.level_count = 2
	end

	for i = 0, world.level_count - 1 do
	-- Draw level indicators
		local lb_indicator = (world.level == i + 1 and img.lb_current) or img.lb_other

		love.graphics.draw(lb_indicator, 113 + (i * 16), 64)
	end
end

function graphics.drawWorldImage()
	local lb_world

	if world.current == 1 or world.current == 3 or world.current == 5 then
		lb_world = img.lb_world1
	elseif world.current == 2 or world.current == 6 then
		lb_world = img.lb_world2
	elseif world.current == 4 then
		lb_world = img.lb_world4
	elseif world.current == 7 then
		lb_world = img.lb_world7
	end

	love.graphics.draw(lb_world, 65, 112)
end

return graphics