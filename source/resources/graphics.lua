local graphics = {}

img_dir = "resources/images/"

img_title_dir = img_dir.."title/" -- Title screen and intro graphics
img_cs_dir = img_dir.."charselect/" -- Character select screen graphics
img_lb_dir = img_dir.."levelbook/" -- Levelbook screen graphics
img_gameplay_dir = img_dir.."gameplay/" -- Gameplay screen graphics
img_chars_dir = img_dir.."gameplay/characters/" -- Character graphics
img_editor_dir = img_dir.."leveleditor/" -- Level editor graphics

function graphics.init()
	graphics.setBackgroundColor("blue")
end

function graphics.load()
	-- Title screen and intro graphics
	do
		img_title_border = love.graphics.newImage(img_title_dir.."border.png")
		img_title_logo = love.graphics.newImage(img_title_dir.."logo.png")
	end

	-- Character select screen graphics
	do
		img_cs_border = love.graphics.newImage(img_cs_dir.."border.png")

		img_cs_mario = love.graphics.newImage(img_cs_dir.."mario.png")
		img_cs_luigi = love.graphics.newImage(img_cs_dir.."luigi.png")
		img_cs_toad = love.graphics.newImage(img_cs_dir.."toad.png")
		img_cs_peach = love.graphics.newImage(img_cs_dir.."peach.png")

		img_cs_mario_active = love.graphics.newImage(img_cs_dir.."mario_active.png")
		img_cs_luigi_active = love.graphics.newImage(img_cs_dir.."luigi_active.png")
		img_cs_toad_active = love.graphics.newImage(img_cs_dir.."toad_active.png")
		img_cs_peach_active = love.graphics.newImage(img_cs_dir.."peach_active.png")

		img_cs_mario_select = love.graphics.newImage(img_cs_dir.."mario_select.png")
		img_cs_luigi_select = love.graphics.newImage(img_cs_dir.."luigi_select.png")
		img_cs_toad_select = love.graphics.newImage(img_cs_dir.."toad_select.png")
		img_cs_peach_select = love.graphics.newImage(img_cs_dir.."peach_select.png")

		img_cs_arrow = love.graphics.newImage(img_cs_dir.."arrow.png")
	end

	-- Levelbook screen graphics
	do
		img_levelbook = love.graphics.newImage(img_lb_dir.."levelbook.png")
		img_lb_current = love.graphics.newImage(img_lb_dir.."level_current.png")
		img_lb_other = love.graphics.newImage(img_lb_dir.."level_other.png")

		img_lb_world1 = love.graphics.newImage(img_lb_dir.."world1.png")
		img_lb_world2 = love.graphics.newImage(img_lb_dir.."world2.png")
		img_lb_world4 = love.graphics.newImage(img_lb_dir.."world4.png")
		img_lb_world7 = love.graphics.newImage(img_lb_dir.."world7.png")
	end

	-- Gameplay screen graphics
	do
		img_gp_filled = love.graphics.newImage(img_gameplay_dir.."lifebar_filled.png")
		img_gp_empty = love.graphics.newImage(img_gameplay_dir.."lifebar_empty.png")
	end

	-- Character graphics
	do
		img_chars_mario = love.graphics.newImage(img_chars_dir.."mario.png")
		img_chars_luigi = love.graphics.newImage(img_chars_dir.."luigi.png")
		img_chars_toad = love.graphics.newImage(img_chars_dir.."toad.png")
		img_chars_peach = love.graphics.newImage(img_chars_dir.."peach.png")
	end

	-- Level editor graphics
	do
		img_editor_16x16_empty = love.graphics.newImage(img_editor_dir.."16x16.png")
		img_editor_16x16_cursor = love.graphics.newImage(img_editor_dir.."16x16_cursor.png")
	end

	-- Tilemap
	img_tilemap = love.graphics.newImage(img_dir.."tilemap.png")

	-- Selection indicator
	img_indicator = love.graphics.newImage(img_dir.."indicator.png")
end

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

function graphics.drawLevelbook()
	love.graphics.draw(img_levelbook, 25, 32)

	graphics.drawText("WORLD  "..tostring(world.current).."-"..tostring(world.level), 89, 48, "brown")

	if world.current < 7 then
		world.level_count = 3
	else
		world.level_count = 2
	end

	for i=0, world.level_count - 1 do
	-- Draw level indicators
		if world.level == i + 1 then
			love.graphics.draw(img_lb_current, 113 + (i * 16), 64)
		else
			love.graphics.draw(img_lb_other, 113 + (i * 16), 64)
		end
	end
end

function graphics.drawWorldImage()
	if world.current == 1 or world.current == 3 or world.current == 5 then love.graphics.draw(img_lb_world1, 65, 112)
	elseif world.current == 2 or world.current == 6 then           love.graphics.draw(img_lb_world2, 65, 112)
	elseif world.current == 4 then                         love.graphics.draw(img_lb_world4, 65, 112)
	elseif world.current == 7 then                         love.graphics.draw(img_lb_world7, 65, 112)
	end
end

return graphics