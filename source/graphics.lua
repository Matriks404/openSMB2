local graphics = {}

graphics.bg = {}
graphics.bg["black"] = { short_name = "BLK", r = 0, g = 0, b = 0 }
graphics.bg["light_blue"] = { short_name = "LBL", r = 0.36, g = 0.58, b = 0.99 }
graphics.bg["blue"] = { short_name = "BLU", r = 0.36, g = 0.58, b = 0.99 }

graphics.width = 256
graphics.height = 240

graphics.scale = 1
graphics.max_scale = 1

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

		local symbol = love.graphics.newQuad(ax, ay, 16, 16, font[color]:getWidth(), font.brown:getHeight())

		love.graphics.draw(font[color], symbol, real_x, y, 0, 0.5)

		real_x = real_x + 8
	end
end

function graphics.drawTile(id, x, y)
	local ax = (id % 16) * 16
	local ay = math.floor(id / 16) * 16

	tile = love.graphics.newQuad(ax, ay, 16, 16, img.tilemap:getWidth(), img.tilemap:getHeight())

	love.graphics.draw(img.tilemap, tile, x, y)
end

function graphics.drawLevelTiles()
	local imin = 0
	local imax = 15

	if state.transition_timer > 0 and state.transition_timer < 35 then
	-- During transition draw additional row of tiles
		if state.screen_y > 0 and state.screen_dir == - 1 then
		-- Draw additional row of tiles on the top
			imin = -1
		end

		if state.screen_y <= ((world.current_area.height - 192) / 16 / 12) and state.screen_dir == 1 then
		-- Draw additional row of tiles on the bottom
			imax = 16
		end
	end

	local trans_y, tile_x, tile_y, pos_x, pos_y

	for i = imin, imax - 1 do
		for j = 0, 16 - 1 do
			if state.transition_timer > 0 then
			-- Draw tiles when transitioning between screens
				if state.screen_y == 0 then
					trans_y = math.floor(state.transition_timer / 35 * 9)
					tile_y = trans_y + i
					pos_y = (i * 16) - (state.transition_timer / 35 * 144) % 16
				else
					if state.screen_dir == 1 then
						trans_y = math.floor(state.transition_timer / 35 * 9)
						tile_y = (state.screen_y * 9) + trans_y + i
						pos_y = (i * 16) - (state.transition_timer / 35 * 144) % 16
					else
						trans_y = 9 - math.floor(state.transition_timer / 35 * 9)
						tile_y = ((state.screen_y - 1) * 9) + trans_y + i
						pos_y = (i * 16) + (state.transition_timer / 35 * 144) % 16
					end
				end
			else
			-- Draw tiles on stationary screen
				if state.screen_y == 0 then
					tile_y = i
				else
					tile_y = (state.screen_y * 9) + i
				end

				pos_y = i * 16
			end

			tile_x = (state.screen_x * 16) + j
			pos_x = j * 16

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

			if state.char_anim_timer >= 5 then
				ax = 0 * 16
			else
				ax = 1 * 16
			end

			state.char_anim_timer = state.char_anim_timer + 1
		else
			ax = 0 * 16

			state.char_anim_timer = 0
		end
	elseif character.current == "luigi" and character.state == "falling" then
	-- Calculate sprite if character is Luigi and falling
		if state.char_anim_timer >= 6 then
			state.char_anim_timer = 0
		end

		if state.char_anim_timer >= 3 then
			ax = 0 * 16
		else
			ax = 1 * 16
		end

		if state.transition_timer == 0 then
			state.char_anim_timer = state.char_anim_timer + 1
		end
	else
		ax = 1 * 16

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

	local sprite

	-- Draw character sprite
	if character.current == "mario" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img.chars_mario:getWidth(), img.chars_mario:getHeight())

		love.graphics.draw(img.chars_mario, sprite, pos_x, pos_y, 0, character.side, 1, offset)

	elseif character.current == "luigi" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img.chars_luigi:getWidth(), img.chars_luigi:getHeight())

		love.graphics.draw(img.chars_luigi, sprite, pos_x, pos_y, 0, character.side, 1, offset)

	elseif character.current == "toad" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img.chars_luigi:getWidth(), img.chars_luigi:getHeight())

		love.graphics.draw(img.chars_toad, sprite, pos_x, pos_y, 0, character.side, 1, offset)

	elseif character.current == "peach" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img.chars_peach:getWidth(), img.chars_peach:getHeight())

		love.graphics.draw(img.chars_peach, sprite, pos_x, pos_y, 0, character.side, 1, offset)
	end

	-- Draw character sprite when it's horizontally wraping
	if character.pos_x > 256 - 16 then
		pos_x = pos_x - world.current_area.width

		if character.current == "mario" then
			love.graphics.draw(img.chars_mario, sprite, pos_x, pos_y, 0, character.side, 1, offset)

		elseif character.current == "luigi" then
			love.graphics.draw(img.chars_luigi, sprite, pos_x, pos_y, 0, character.side, 1, offset)

		elseif character.current == "toad" then
			love.graphics.draw(img.chars_toad, sprite, pos_x, pos_y, 0, character.side, 1, offset)

		elseif character.current == "peach" then
			love.graphics.draw(img.chars_peach, sprite, pos_x, pos_y, 0, character.side, 1, offset)
		end
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
		if world.level == i + 1 then
			love.graphics.draw(img.lb_current, 113 + (i * 16), 64)
		else
			love.graphics.draw(img.lb_other, 113 + (i * 16), 64)
		end
	end
end

function graphics.drawWorldImage()
	if world.current == 1 or world.current == 3 or world.current == 5 then
		love.graphics.draw(img.lb_world1, 65, 112)
	elseif world.current == 2 or world.current == 6 then
		love.graphics.draw(img.lb_world2, 65, 112)
	elseif world.current == 4 then
		love.graphics.draw(img.lb_world4, 65, 112)
	elseif world.current == 7 then
		love.graphics.draw(img.lb_world7, 65, 112)
	end
end

function graphics.drawStartingPosition()
	local start_x = world.current_level.start_x
	local start_y = world.current_level.start_y

	graphics.drawText("S", start_x, start_y, "brown")
end

return graphics