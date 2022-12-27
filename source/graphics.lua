local graphics = {}

function graphics.setBackgroundColor(color)
	if color == "black" then
		love.graphics.setBackgroundColor(0, 0, 0)

	elseif color == "light_blue" then

		love.graphics.setBackgroundColor(0.24, 0.74, 0.99)
	elseif color == "blue" then

		love.graphics.setBackgroundColor(0.36, 0.58, 0.99)
	end
end

function graphics.drawText(str, x, y, color)
	realx = 0

	for i=0, string.len(str) - 1 do
		posx = x + (i * 16)
		if realx == 0 then realx = posx end

		code = string.byte(str, i + 1)

		ax = (code % 32) * 16
		ay = math.floor(code / 32) * 16

		if color == "brown" then
			symbol = love.graphics.newQuad(ax, ay, 16, 16, font_brown:getWidth(), font_brown:getHeight())

			love.graphics.draw(font_brown, symbol, realx, y, 0, 0.5)
		else
			symbol = love.graphics.newQuad(ax, ay, 16, 16, font_white:getWidth(), font_white:getHeight())

			love.graphics.draw(font_white, symbol, realx, y, 0, 0.5)
		end

		realx = realx + 8
	end
end

function graphics.drawTile(tileid, tilex, tiley)
	ax = (tileid % 16) * 16
	ay = math.floor(tileid / 16) * 16

	tile = love.graphics.newQuad(ax, ay, 16, 16, img_tilemap:getWidth(), img_tilemap:getHeight())

	love.graphics.draw(img_tilemap, tile, tilex, tiley)
end

function graphics.drawLevelTiles()
	imin = 0
	imax = 15

	if state.transition_timer > 0 and state.transition_timer < 35 then
	-- During transition draw additional row of tiles
		if state.screen_y > 0 and screendir == - 1 then
		-- Draw additional row of tiles on the top
			imin = -1
		end

		if state.screen_y <= ((world.area_heights[world.area] - 192) / 16 / 12) and screendir == 1 then
		-- Draw additional row of tiles on the bottom
			imax = 16
		end
	end

	for i=imin, imax - 1 do
		for j=0, 16 - 1 do
			if state.transition_timer > 0 then
			-- Draw tiles when transitioning between screens
				if state.screen_y == 0 then
					transy = math.floor(state.transition_timer / 35 * 9)
					tiley = transy + i
					posy = (i * 16) - (state.transition_timer / 35 * 144) % 16
				else
					if screendir == 1 then
						transy = math.floor(state.transition_timer / 35 * 9)
						tiley = (state.screen_y * 9) + transy + i
						posy = (i * 16) - (state.transition_timer / 35 * 144) % 16

					else
						transy = 9 - math.floor(state.transition_timer / 35 * 9)
						tiley = ((state.screen_y - 1) * 9) + transy + i

						posy = (i * 16) + (state.transition_timer / 35 * 144) % 16
					end
				end
			else
			-- Draw tiles on stationary screen
				if state.screen_y == 0 then
					tiley = i
				else
					tiley = (state.screen_y * 9) + i
				end

				posy = i * 16
			end

			tilex = (state.screen_x * 16) + j

			graphics.drawTile(world.area_tiles[tiley][tilex], j * 16, posy)
		end
	end
end

function graphics.drawCharacter()
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
		posy = character.pos_y - state.screen_y * 240

	else
		posy = character.pos_y - state.screen_y * 144
	end

	if state.transition_timer > 0 then
		if screendir == 1 then posy = posy - (state.transition_timer / 35) * 144
		else                   posy = posy + (state.transition_timer / 35) * 144
		end
	end

	-- Draw character sprite
	if character.current == "mario" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_chars_mario:getWidth(), img_chars_mario:getHeight())

		love.graphics.draw(img_chars_mario, sprite, character.pos_x, posy, 0, character.side, 1, offset)

	elseif character.current == "luigi" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_chars_luigi:getWidth(), img_chars_luigi:getHeight())

		love.graphics.draw(img_chars_luigi, sprite, character.pos_x, posy, 0, character.side, 1, offset)

	elseif character.current == "toad" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_chars_luigi:getWidth(), img_chars_luigi:getHeight())

		love.graphics.draw(img_chars_toad, sprite, character.pos_x, posy, 0, character.side, 1, offset)

	elseif character.current == "peach" then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_chars_peach:getWidth(), img_chars_peach:getHeight())

		love.graphics.draw(img_chars_peach, sprite, character.pos_x, posy, 0, character.side, 1, offset)
	end

	-- Draw character sprite when it's horizontally wraping
	if character.pos_x > 256 - 16 then
		if character.current == "mario" then
			love.graphics.draw(img_chars_mario, sprite, character.pos_x - world.area_widths[world.area], posy, 0, character.side, 1, offset)

		elseif character.current == "luigi" then
			love.graphics.draw(img_chars_luigi, sprite, character.pos_x - world.area_widths[world.area], posy, 0, character.side, 1, offset)

		elseif character.current == "toad" then
			love.graphics.draw(img_chars_toad, sprite, character.pos_x - world.area_widths[world.area], posy, 0, character.side, 1, offset)

		elseif character.current == "peach" then
			love.graphics.draw(img_chars_peach, sprite, character.pos_x - world.area_widths[world.area], posy, 0, character.side, 1, offset)
		end
	end
end

return graphics