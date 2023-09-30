local graphics = {}

graphics.bg = {
	black = { short_name = "BLK", r = 0, g = 0, b = 0 },
	light_blue = { short_name = "LBL", r = 0.36, g = 0.58, b = 0.99 },
	blue = { short_name = "BLU", r = 0.36, g = 0.58, b = 0.99 }
}

graphics.images = {}

graphics.width = 256
graphics.height = 240

graphics.scale = 1
graphics.max_scale = 1

graphics.tile_size = 16

function graphics.init()
	love.graphics.setDefaultFilter("nearest")

	graphics.load3DSButtonImages()
end

function graphics.load3DSButtonImages()
	local directory = "resources/images/platform_specific/3ds/buttons/"

	-- These are mandatory.
	local list = {
		["btn_3ds_up"] = { directory.."up.t3x", true },
		["btn_3ds_down"] = { directory.."down.t3x", true },
		["btn_3ds_left"] = { directory.."left.t3x", true },
		["btn_3ds_right"] = { directory.."right.t3x", true },

		["btn_3ds_a"] = { directory.."a.t3x", true },
		["btn_3ds_b"] = { directory.."b.t3x", true },
		["btn_3ds_x"] = { directory.."x.t3x", true },
		["btn_3ds_y"] = { directory.."y.t3x", true },

		["btn_3ds_l"] = { directory.."l.t3x", true },
		["btn_3ds_r"] = { directory.."r.t3x", true }

	}

	resources.loadImages(graphics.images, list)
end

function graphics.loadWorldImages()
	graphics.world_images = {
		[1] = game_resources.images.lb_world1,
		[2] = game_resources.images.lb_world2,
		[3] = game_resources.images.lb_world1,
		[4] = game_resources.images.lb_world4,
		[5] = game_resources.images.lb_world1,
		[6] = game_resources.images.lb_world2,
		[7] = game_resources.images.lb_world7
	}
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
	if graphics.bg[color] then
		if graphics.current_bg ~= color then
			local color = graphics.bg[color]
			local r, g, b = color.r, color.g, color.b

			love.graphics.setBackgroundColor(r, g, b)
		end

		graphics.current_bg = color
	else
		love.graphics.setBackgroundColor(0, 0, 0)

		graphics.current_bg = "black"
	end
end

function graphics.drawText(str, x, y, font_id)
	local s = state.s[state.name]
	local font_id = font_id or s.font
	local font = resources.font[font_id]

	local pos_x = x
	local pos_y = y

	local x_gap = font.symbol_size / 2

	for i = 1, #str do
		local char = string.byte(str, i)
		local quad = font.glyphs[char]

		love.graphics.draw(font.img, quad, pos_x, pos_y, 0, 0.5)

		pos_x = pos_x + x_gap
	end
end

function graphics.drawTextAlignedToRight(str, x, y, font_id)
	local str_width = string.len(str) * 8
	local x = x + 8 - str_width

	graphics.drawText(str, x, y, font_id)
end

function graphics.drawTile(id, x, y)
	local tile_x = (id % 16) * 16
	local tile_y = math.floor(id / 16) * 16

	local tilemap_width = game_resources.images.tilemap:getWidth()
	local tilemap_height = game_resources.images.tilemap:getHeight()

	local tile = love.graphics.newQuad(tile_x, tile_y, 16, 16, tilemap_width, tilemap_height)

	love.graphics.draw(game_resources.images.tilemap, tile, x, y)
end

function graphics.drawLevelTiles()
	local top_y, bottom_y = 0, 15

	local trans_y, trans_offset, tile_x, tile_y, pos_x, pos_y

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
		trans_offset = (state.transition_timer / 35 * 144) % graphics.tile_size
	end

    for i = top_y, bottom_y - 1 do
        if state.transition_timer > 0 then
			if state.screen_dir == 1 then
				tile_y = (state.screen_y * 9) + trans_y + i
			else
				tile_y = ((state.screen_y - 1) * 9) + trans_y + i
			end

			pos_y = (i * graphics.tile_size) + trans_offset * -(state.screen_dir)
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
	local offset, tile_x, pos_y
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

			tile_x = (state.char_anim_timer >= 5 and 0) or 16

			state.char_anim_timer = state.char_anim_timer + 1
		else
			tile_x = 0

			state.char_anim_timer = 0
		end
	elseif character.current == "char2" and character.state == "falling" then
	-- Calculate sprite if character is Luigi and falling
		if state.char_anim_timer >= 6 then
			state.char_anim_timer = 0
		end

		tile_x = (state.char_anim_timer >= 3 and 0) or 16

		if state.transition_timer == 0 then
			state.char_anim_timer = state.char_anim_timer + 1
		end
	else
		tile_x = 16

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

	local char

	-- Draw character sprite
	if character.current == "char1" then
		char = game_resources.images.gp_char1

	elseif character.current == "char2" then
		char = game_resources.images.gp_char2

	elseif character.current == "char3" then
		char = game_resources.images.gp_char3

	elseif character.current == "char4" then
		char = game_resources.images.gp_char4
	end

	--TODO: Should we initially generate quads like we generate symbols for fonts?
	local sprite = love.graphics.newQuad(tile_x, 0, 16, 32, char:getWidth(), char:getHeight())
	love.graphics.draw(char, sprite, pos_x, pos_y, 0, character.side, 1, offset)

	-- Draw character sprite when it's horizontally wraping
	if character.pos_x > 256 - 16 then
		pos_x = pos_x - world.current_area.width

		love.graphics.draw(char, sprite, pos_x, pos_y, 0, character.side, 1, offset)
	end
end

function graphics.drawLevelbook()
	local lb_x = 25
	local lb_y = 32

	if game_resources.images.levelbook then
		love.graphics.draw(game_resources.images.levelbook, lb_x, lb_y)
	end

	local world_str = string.format("WORLD  %d-%d", world.current, world.level)
	local world_x = 89
	local world_y = 48

	graphics.drawText(world_str, world_x, world_y)

	world.level_count = (world.current < 7) and 3 or 2

	local lb_indicator_x = 113
	local lb_indicator_spacing = 16
	local lb_indicator_y = 64

	local x, y

	-- Draw level indicators
	for i = 1, world.level_count do
		x = lb_indicator_x + ((i - 1) * lb_indicator_spacing)
		y = lb_indicator_y

		if world.level == i and game_resources.images.lb_current then
			if game_resources.images.lb_current then
				love.graphics.draw(game_resources.images.lb_current, x, y)
			end
		else
			if game_resources.images.lb_other then
				love.graphics.draw(game_resources.images.lb_other, x, y)
			end
		end
	end
end

function graphics.drawWorldImage()
	local lb_world = graphics.world_images[world.current]

	if lb_world then
		love.graphics.draw(lb_world, 65, 112)
	end
end

return graphics