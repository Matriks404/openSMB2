function love.load()
	gametitle = "openSMB2"

	-- Setting up window
	love.window.setMode(256, 240, {vsync = true}) -- 256x240 is a NES resolution
	love.window.setTitle(gametitle)
	love.filesystem.setIdentity(gametitle)

	love.graphics.setBackgroundColor(92, 148, 252)

	-- Loading resources
	loadFonts()
	loadGraphics()
	loadMusic()
	loadSoundEffects()
	loadStory()

	state = 0 -- Game state (0 - title screen, 1 - intro, 2 - character select, 3 - level intro, 4 - gameplay 98 - level editor 99 - debug screen)

	-- Debugging variables
	debugmode = false
	debugfps = true
	debugframes = true
	debugmute = false

	-- Timers
	timer = 0
	texttimer = 0
	transitiontimer = 0

	transition = false

	-- Text variables
	textlines = 0
	textpage = 0

	cursor = 0 -- Menu cursor variable

	-- Level editor variables
	editoroption = 0 -- Editor option (0 - Level select, 1 - Editing screen)
	editheight = 0
	editwidth = 0
	edittile = 1

	-- Editor cursor coordinates
	editcurx = 0
	editcury = 0

	-- Editor selected tile coordinates
	edittilex = 0
	edittiley = 0

	-- Editor view coordinates
	editviewx = 0
	editviewy = 0

	-- Gameplay
	character = 0 -- Character (0 - Mario, 2 - Luigi, 3 - Toad, 4 - Princess Peach)
	lifes = 2
	energy = 2
	energybars = 2

	-- Keep in mind that these are repeated in certain point of code, as player will return to title screen after game completion,
	-- but variables here are initialized only on game execution start, so the game shouldn't rely on this.
	world = 1

	alllevels = 3
	level = 1

	allareas = 1
	area = 0
	areawidth = {} -- Array of area widths
	areaheight = {} -- Array of area heights
	areabg = {} -- Array of backgrounds (0 - Black, 1 - Blue)
	areamusic = {} -- Array of music (0 - Overworld, 1 - Underworld)
	areatiles = {} -- Array of area tiles

	-- Screen position
	screenx = 0
	screeny = 0

	-- Start coordinates
	startx = 0
	starty = 0

	-- Character coordinates
	herox = 0
	heroy = 0

	-- Character position subpixels
	herosubx = 0
	herosuby = 0

	heroside = 1 -- On which side character is looking at (0 - Left, 1 - Right)
	herospeed = 0 -- Character speed
end

function love.update()
	timer = timer + 1

	if state == 0 then
	-- Title screen stuff
		mus_title:play()

		-- After some time go to intro story
		if(timer == 500) then
			state = 1
			timer = 0
		end

	elseif state == 1 then
	-- Intro story stuff
		if transition == true then
			transitiontimer = transitiontimer + 1

			-- After some time after showing 2nd story page go to title screen again
			if transitiontimer == 442 then
				state = 0
				timer = 0
				texttimer = 0

				textlines = 0
				textpage = 0

				transitionClear()
			end
		end

	elseif state == 2 then
	-- Character select stuff
		if transition == true then
			transitiontimer = transitiontimer + 1

			-- After some time after chosing character go to levelbook screen
			if transitiontimer == 136 then
				state = 3
				timer = 0

				transitionClear()

				mus_charsel:stop()

				character = cursor -- Chosen character is one that was selected previously by cursor
			end
		end

	elseif state == 3 then
	-- Levelbook stuff
		if timer == 94 then
			state = 4
			timer = 0

			loadLevel()

			herox = startx
			heroy = starty
		end

	elseif state == 4 then
	-- Gameplay stuff

		if timer > 146 then
			-- Left/Right movement
			if love.keyboard.isDown("left") then
				heroside = -1
				herospeed = 24

			elseif love.keyboard.isDown("right") then
				heroside = 1
				herospeed = 24
			else
				herospeed = 0
			end

			-- Calculating character position
			if herospeed > 0 then
				herosubx = herosubx + herospeed * heroside
			
				while herosubx >= 16 or herosubx <= -16 do
					herosubx = herosubx - 16 * heroside
					herox = herox + heroside
				end
			end

			--TODO: More physics!
		end
	end
end

function love.keyreleased(key)
	-- Quit if user pressed ESC key
	if key == "escape" then
		love.event.quit()
	end

	-- Title screen, intro story or debug screen
	if state == 0 or state == 1 or state == 99 then
		if key == "s" then
		-- Go to character screen
			state = 2
			timer = 0

			mus_title:stop()

			if debugmute == false then
				mus_charsel:play()
			end

			-- Set up gameplay variables just after leaving title screen, as player will return to character select screen every completion of level.
			world = 1
			level = 1

			lifes = 2
			energy = 2
			energybars = 2

			love.graphics.setBackgroundColor(0, 0, 0)

		elseif love.keyboard.isDown("lctrl") and key == "d" then
		-- Go to debug screen or title screen (depending on origin screen)
			if debugmode == false then
				state = 99
				timer = 0
				debugmode = true

				mus_title:stop()
			else
				state = 0
				timer = 0
				debugmode = false
				debugmute = false
			end
		end
	end

	if state == 2 then
	-- Character select screen
		if key == "left" and transitiontimer == 0 then
		-- Select character on the left
			if cursor > 0 then
				cursor = cursor - 1
			else
				cursor = 3
			end

			sfx_cherry:play()

		elseif key == "right" and transitiontimer == 0 then
		-- Select character on the right
			if cursor < 3 then
				cursor = cursor + 1
			else
				cursor = 0
			end

			sfx_cherry:play()

		elseif key == "x" and transitiontimer == 0 then
		-- Choose character and enable transition which will go to levelbook after some time
			transition = true

			sfx_cherry:play()
		end

	elseif state == 4 then

		if debugmode == true then
		-- Moving screen debug feature
			-- Move screen around using arrow keys
			--if key == "kp4" and screenx > 0 then
			--	screenx = screenx - 1

			--elseif key == "kp6" and screeny < ((areawidth[area] / 16 / 16) - 1) then
			--	screenx = screenx + 1

			if key == "kp8" and screeny > 0 then
				screeny = screeny - 1

			elseif key == "kp2" and screeny < ((areaheight[area] / 16 / 15) - 1) then
				screeny = screeny + 1
			end
		end

	elseif state == 98 then
	-- Level editor screen
		if editoroption == 0 then
		-- Level select
			-- Set world according to world table
			if key >= "1" and key <= "3" then                  world = 1
			elseif key >= "4" and key <= "6" then              world = 2
			elseif key >= "7" and key <= "9" then              world = 3
			elseif key == "a" or key == "b" or key == "c" then world = 4
			elseif key == "d" or key == "e" or key == "f" then world = 5
			elseif key == "g" or key == "h" or key == "i" then world = 6
			elseif key == "j" or key == "k" then               world = 7
			end

			-- Go to proper editor
			if key >= "1" and key <= "9" then
				editoroption = 1
				level = ((key - 1) % 3) + 1
				area = 0

				loadLevel()

			elseif string.byte(key) >= string.byte("a") and string.byte(key) <= string.byte("k") then
				editoroption = 1
				level = ((string.byte(key) - 97) % 3) + 1
				area = 0

				loadLevel()

			elseif key == "q" then
			-- Quit menu to debug screen
				state = 99
				timer = 0

				love.graphics.setBackgroundColor(92, 148, 252)
			end

		elseif editoroption == 1 then
		-- Edit map option
			if key == "b" then
			-- Change background color
				if areabg[area] == 0 then
					areabg[area] = 1

					love.graphics.setBackgroundColor(60, 180, 282)
				else
					areabg[area] = 0

					love.graphics.setBackgroundColor(0, 0, 0)
				end

			elseif key == "m" then
			-- Change music
				if areamusic[area] < 2 then
					areamusic[area] = areamusic[area] + 1

					playAreaMusic()
				else
					areamusic[area] = 0

					playAreaMusic()
				end

			-- Shrink or scratch width/height
			elseif key == "kp4" then
				if areawidth[area] > 16 then
					areawidth[area] = areawidth[area] - 16

					checkEditCursorBounds()
					checkEditGridBounds()
				end

			elseif key == "kp6" then
				if areawidth[area] < 3744 then
					areawidth[area] = areawidth[area] + 16

					checkEditCursorBounds()
					checkEditGridBounds()

					for i=0, (areaheight[area] / 16) - 1 do
					-- Clear newly added tile blocks
						areatiles[i][(areawidth[area] / 16) - 1] = 0
					end
				end

			elseif key == "kp8" then
				if areaheight[area] > 16 then
					areaheight[area] = areaheight[area] - 16

					checkEditCursorBounds()
					checkEditGridBounds()
				end

			elseif key == "kp2" then
				if areaheight[area] < 1440 then
					areaheight[area] = areaheight[area] + 16

					checkEditCursorBounds()
					checkEditGridBounds()

					-- Clear newly added tile blocks
					areatiles[(areaheight[area] / 16) - 1] = {}

					for j=0, (areawidth[area] / 16) - 1 do
						areatiles[(areaheight[area] / 16) - 1][j] = 0
					end
				end

			-- Change current areas
			elseif key == "[" then
				saveLevel()

				if area > 0 then
					area = area - 1

				else
					area  = allareas - 1

				end

				loadArea()

				editcurx = 0
				editcury = 0

				editviewx = 0
				editviewy = 0

			elseif key == "]" then
				saveLevel()

				if area < allareas - 1 then
					area = area + 1

				else
					area = 0

				end

				loadArea()

				editcurx = 0
				editcury = 0

				editviewx = 0
				editviewy = 0

			-- Move edit cursor
			elseif key == "left" and editcurx > 0 then
				editcurx = editcurx - 16

				checkEditGridBounds()

			elseif key == "right" and editcurx < areawidth[area] - 16 then
				editcurx = editcurx + 16

				checkEditGridBounds()

			elseif key == "up" and editcury > 0 then
				editcury = editcury - 16

				checkEditGridBounds()

			elseif key == "down" and editcury < areaheight[area] - 16 then
				editcury = editcury + 16

				checkEditGridBounds()

			-- Change selected tile
			elseif key == "w" and edittile > 15 then
				edittile = edittile - 16

			elseif key == "s" and edittile < 240 then
				edittile = edittile + 16

			elseif key == "a" and edittile > 0 then
				edittile = edittile - 1

			elseif key == "d" and edittile < 255 then
				edittile = edittile + 1

			elseif key == "z" then
			-- Remove tile
				placeTile(0)

			elseif key == "x" then
			-- Place tile
				placeTile(edittile)

			elseif key == "l" then
			-- Load this level from file
				loadLevel()

			elseif key == "v" then
			-- Save this level to file
				saveLevel()

			elseif key == "p" then
			-- Play from this level (doesn't return to level editor)
				saveLevel()

				state = 2
				area = 0
				frames = 0

				if debugmute == false then
					stopAreaMusic()
					mus_charsel:play()
				end

				love.graphics.setBackgroundColor(0, 0, 0)


			elseif key == "q" then
			-- Quit to editor menu
				quitEditor()

			elseif key == "e" then
			-- Quit to editor menu and save level
				saveLevel()
				quitEditor()
			end
		end

	elseif state == 99 then
	-- Debug screen
		if key == "f" then
		-- Show FPS counter or not
			if debugfps == false then
				debugfps = true
			else
				debugfps = false
			end

		elseif key == "r" then
		-- Show frames counter or not
			if debugframes == false then
				debugframes = true
			else
				debugframes = false
			end

		-- Mute music or not
		elseif key == "m" then
			if debugmute == false then
				debugmute = true
			else
				debugmute = false
			end

		elseif key == "l" then
		-- Go to level editor
			state = 98
			timer = 0

			debugframes = false
			editoroption = 0

			love.graphics.setBackgroundColor(0, 0, 0)
		end
	end
end

function love.draw()
	if state == 0 or state == 1 or state == 99 then
	-- Draw border on title screen and intro
		love.graphics.draw(img_titleborder, 0, 0)
	end

	if state == 0 then
	-- Draw title screen stuff
		love.graphics.draw(img_titlelogo, 48, 48)

		drawFont("!\"", 193, 72)
		drawFont("#1988 NINTENDO", 72, 184)

	elseif state == 1 then
	-- Draw intro story stuff
		if timer > 34 then
			drawFont("STORY", 112, 40)

			if texttimer > 65 then
			-- Based on timer add new line of text
				textlines = textlines + 1
				texttimer = 0

				if textpage == 0 and textlines > 8 then
				-- Change to 2nd story page if all lines are displayed
					textlines = 0
					textpage = 1
					texttimer = 50

				elseif textpage == 1 and textlines > 8 then
				-- Enable transition which will go to title screen after some time
					textlines = 8
					transition = true
				end
			end

			texttimer = texttimer + 1

			for i=0, textlines do
			-- Draw lines of text
				if textpage == 0 then
					drawFont(tostring(story1[i]), 48, 64 + ((i - 1) * 16))
				else
					drawFont(tostring(story2[i]), 48, 64 + ((i - 1) * 16))
				end
			end
		end

	elseif state == 2 then
	-- Draw character select screen stuff
		love.graphics.draw(img_charselborder, 0, 0)

		drawFont("PLEASE SELECT", 72, 80)
		drawFont("PLAYER", 96, 96)

		love.graphics.draw(img_arrow, 72 + (cursor * 32), 112)

		if cursor == 0 then
		-- Draw Mario
			if transitiontimer < 3 or transitiontimer > 68 then
				love.graphics.draw(img_cs_mario_active, 72, 144)
			else
				love.graphics.draw(img_cs_mario_select, 72, 144)
			end
		else
			love.graphics.draw(img_cs_mario, 72, 144)
		end

		if cursor == 1 then
		-- Draw Luigi
			if transitiontimer < 3 or transitiontimer > 68 then
				love.graphics.draw(img_cs_luigi_active, 104, 144)
			else
				love.graphics.draw(img_cs_luigi_select, 104, 144)
			end
		else
			love.graphics.draw(img_cs_luigi, 104, 144)
		end

		if cursor == 2 then
		-- Draw Toad
			if transitiontimer < 3 or transitiontimer > 68 then
				love.graphics.draw(img_cs_toad_active, 136, 144)
			else
				love.graphics.draw(img_cs_toad_select, 136, 144)
			end
		else
			love.graphics.draw(img_cs_toad, 136, 144)
		end

		if cursor == 3 then
		-- Draw Peach
			if transitiontimer < 3 or transitiontimer > 68 then
				love.graphics.draw(img_cs_peach_active, 168, 144)
			else
				love.graphics.draw(img_cs_peach_select, 168, 144)
			end
		else
			love.graphics.draw(img_cs_peach, 168, 144)
		end

		drawFont("EXTRA LIFE", 64, 208, true)
		drawFont(tostring(lifes), 184, 208, true)

	elseif state == 3 then
	-- Draw levelbook
		love.graphics.draw(img_levelbook, 25, 32)

		drawFont("WORLD  "..tostring(world).."-"..tostring(level), 89, 48, "brown")

		if world < 7 then
			alllevels = 3
		else
			alllevels = 2
		end

		for i=0, alllevels - 1 do
		-- Draw level indicators
			if level == i + 1 then
				love.graphics.draw(img_lb_current, 113 + (i * 16), 64)
			else
				love.graphics.draw(img_lb_other, 113 + (i * 16), 64)
			end
		end

		-- Draw world image
		if world == 1 or world == 3 or world == 5 then love.graphics.draw(img_lb_1, 65, 112)
		elseif world == 2 or world == 6 then           love.graphics.draw(img_lb_2, 65, 112)
		elseif world == 4 then                         love.graphics.draw(img_lb_4, 65, 112)
		elseif world == 7 then                         love.graphics.draw(img_lb_7, 65, 112)
		end

	elseif state == 4 then
	-- Draw gameplay stuff
		if timer > 144 then
			for i=0, 15 - 1 do
				for j=0, 16 - 1 do
					drawTile(areatiles[(screeny * 15) + i][(screenx * 16) + j], j * 16, i * 16)
				end
			end
		end

		if timer > 146 then
		-- Draw everything else
			for i=0, energybars - 1 do
			-- Draw energy bars
				if i+1 <= energy then
					love.graphics.draw(img_g_filled, 12, 48 + (i * 16))
				else
					love.graphics.draw(img_g_empty, 12, 48 + (i * 16))
				end
			end

			-- Calculate offset for character sprite
			if heroside == -1 then
				offset = 16

			elseif heroside == 1 then
				offset = 0
			end

			-- Draw character on screen --TODO: Improve
			if character == 0 then
				love.graphics.draw(img_char_mario, herox, heroy, 0, heroside, 1, offset)

			elseif character == 1 then
				love.graphics.draw(img_char_luigi, herox, heroy, 0, heroside, 1, offset)

			elseif character == 2 then
				love.graphics.draw(img_char_toad, herox, heroy, 0, heroside, 1, offset)

			elseif character == 3 then
				love.graphics.draw(img_char_peach, herox, heroy, 0, heroside, 1, offset)
			end

			--TODO: Draw entities
		end

	elseif state == 98 then
	-- Draw level editor stuff
		if editoroption == 0 then
		-- Draw level editor menu
			drawFont("OPENSMB2 ALPHA  0.2", 32, 32)
			drawFont("LEVEL EDITOR", 32, 48)

			drawFont("LEVEL SELECT", 32, 80)

			drawFont(" 1 - 1-1  4 - 2-1  7 - 3-1", 32, 96)
			drawFont(" 2 - 1-2  5 - 2-2  8 - 3-2", 32, 112)
			drawFont(" 3 - 1-3  6 - 2-3  9 - 3-3", 32, 128)

			drawFont(" A - 4-1  D - 5-1  G - 6-1", 32, 160)
			drawFont(" B - 4-2  E - 5-2  H - 6-2", 32, 176)
			drawFont(" C - 4-3  F - 5-3  I - 6-3", 32, 192)

			drawFont(" J - 7-1  K - 7-2  Q - QUIT", 32, 224)

		elseif editoroption == 1 then
		-- Draw editor
			-- Draw world, level and area indicators
			drawFont(tostring(world).."-"..tostring(level), 64, 2)
			drawFont("A-"..tostring(area), 104, 2)

			-- Draw background value
			if areabg[area] == 0 then
				drawFont("BG-BLK", 144, 2)
			else
				drawFont("BG-BLU", 144, 2)
			end

			-- Draw music indicator
			if areamusic[area] == 0 then
				drawFont("M-OVER", 208, 2)
			elseif areamusic[area] == 1 then
				drawFont("M-UNDR", 208, 2)
			else
				drawFont("M-BOSS", 208, 2)
			end

			-- Draw width and height values
			drawFont("W-"..tostring(areawidth[area]), 2, 10)
			drawFont("H-"..tostring(areaheight[area]), 56, 10)

			-- Draw currently selected tile
			drawFont("T-"..tostring(edittile), 120, 10)
			drawTile(edittile, 152, 10)

			-- Draw coordinates for edit cursor
			drawFont(tostring(editcurx), 184, 10)
			drawFont(",", 216, 10)
			drawFont(tostring(editcury), 224, 10)

			-- Calculate height and width of edit view
			editheight = areaheight[area] - editviewy
			editwidth = areawidth[area] - editviewx

			if editheight > 208 then
				editheight = 208
			end

			if editwidth > 256 then
				editwidth = 256
			end

			-- Draw boxes for each square
			for i=0, (editheight / 16) - 1 do
				for j=0, (editwidth / 16) - 1 do
					love.graphics.draw(img_le_16x16, j * 16, 32 + (i * 16))
				end
			end

			-- Draw tiles
			for i=0, (editheight / 16) - 1 do
				for j=0, (editwidth / 16) - 1 do
					drawTile(areatiles[(editviewy / 16) + i][(editviewx / 16) + j], j * 16, 32 + (i * 16))
				end
			end

			-- Draw edit cursor
			love.graphics.draw(img_le_16x16_cur, editcurx - editviewx, editcury - editviewy + 32)


			--TODO: Add more!
		end

	elseif state == 99 then
	-- Draw debug screen stuff
		drawFont("OPENSMB2 DEBUG MODE", 48, 56)
		drawFont("F-TOGGLE FPS COUNTER", 48, 80)
		drawFont("R-TOGGLE FRAME COUNTER", 48, 96)
		drawFont("M-TOGGLE MUSIC MUTE", 48, 112)
		drawFont("L-ENTER LEVEL EDITOR", 48, 128)
		drawFont("S-START GAME RIGHT NOW", 48, 144)

		drawFont("ENABLED FLAGS", 64, 160)

		if debugfps == true then
			drawFont("FPS", 64, 176)
		end

		if debugframes == true then
			drawFont("FRAMES", 104, 176)
		end

		if debugmute == true then
			drawFont("MUTED", 168, 176)
		end
	end

	-- Draw debug stuff
	if debugmode == true then
		-- Draw FPS
		if debugfps == true then
			drawFont(tostring(love.timer.getFPS()).." FPS", 2, 2)
		end

		-- Draw lasted frames
		if debugframes == true then
			timerx = 0
			n = timer

			while n>0 do
				timerx = timerx + 1
				n = math.floor(n / 10)
			end

			drawFont(tostring(timer), 256 - (timerx * 8), 2)
		end
	end
end

function loadFonts()
	fontdir = "resources/images/font/" -- Fonts folder

	font_white = love.graphics.newImage(fontdir.."white.png")
	font_brown = love.graphics.newImage(fontdir.."brown.png")
end

function loadGraphics()
	-- Title screen and intro graphics
	imgti = "resources/images/title/"

	img_titleborder = love.graphics.newImage(imgti.."border.png")
	img_titlelogo = love.graphics.newImage(imgti.."logo.png")

	-- Character select screen graphics
	imgcs = "resources/images/charselect/"

	img_charselborder = love.graphics.newImage(imgcs.."border.png")

	img_cs_mario = love.graphics.newImage(imgcs.."mario.png")
	img_cs_luigi = love.graphics.newImage(imgcs.."luigi.png")
	img_cs_toad = love.graphics.newImage(imgcs.."toad.png")
	img_cs_peach = love.graphics.newImage(imgcs.."peach.png")

	img_cs_mario_active = love.graphics.newImage(imgcs.."mario_active.png")
	img_cs_luigi_active = love.graphics.newImage(imgcs.."luigi_active.png")
	img_cs_toad_active = love.graphics.newImage(imgcs.."toad_active.png")
	img_cs_peach_active = love.graphics.newImage(imgcs.."peach_active.png")

	img_cs_mario_select = love.graphics.newImage(imgcs.."mario_select.png")
	img_cs_luigi_select = love.graphics.newImage(imgcs.."luigi_select.png")
	img_cs_toad_select = love.graphics.newImage(imgcs.."toad_select.png")
	img_cs_peach_select = love.graphics.newImage(imgcs.."peach_select.png")

	img_arrow = love.graphics.newImage(imgcs.."arrow.png")

	-- Levelbook screen graphics
	imglb = "resources/images/levelbook/"

	img_levelbook = love.graphics.newImage(imglb.."levelbook.png")
	img_lb_current = love.graphics.newImage(imglb.."level_current.png")
	img_lb_other = love.graphics.newImage(imglb.."level_other.png")

	img_lb_1 = love.graphics.newImage(imglb.."world1.png")
	img_lb_2 = love.graphics.newImage(imglb.."world2.png")
	img_lb_4 = love.graphics.newImage(imglb.."world4.png")
	img_lb_7 = love.graphics.newImage(imglb.."world7.png")

	-- Gameplay screen graphics
	imgg = "resources/images/gameplay/"

	img_g_filled = love.graphics.newImage(imgg.."lifebar_filled.png")
	img_g_empty = love.graphics.newImage(imgg.."lifebar_empty.png")

	-- Level editor graphics
	imgle = "resources/images/leveleditor/"

	img_le_16x16 = love.graphics.newImage(imgle.."16x16.png")
	img_le_16x16_cur = love.graphics.newImage(imgle.."16x16_cursor.png")

	-- Tilemap graphics
	img_tiles = love.graphics.newImage("resources/images/tilemap.png")

	-- Load character graphics
	img_char_mario = love.graphics.newImage("resources/images/gameplay/characters/mario.png")
	img_char_luigi = love.graphics.newImage("resources/images/gameplay/characters/luigi.png")
	img_char_toad = love.graphics.newImage("resources/images/gameplay/characters/toad.png")
	img_char_peach = love.graphics.newImage("resources/images/gameplay/characters/peach.png")

end

function loadMusic()
	musdir = "resources/sound/music/" -- Music folder

	mus_title = love.audio.newSource(musdir.."title.ogg")
	mus_charsel = love.audio.newSource(musdir.."charselect.ogg")
	mus_overworld = love.audio.newSource(musdir.."overworld.ogg")
	mus_underworld = love.audio.newSource(musdir.."underworld.ogg")
	mus_boss = love.audio.newSource(musdir.."boss.ogg")
end

function loadSoundEffects()
	sfxdir = "resources/sound/effects/" -- Sound effects folder

	sfx_cherry = love.audio.newSource(sfxdir.."cherry.ogg")
end

function loadStory()
	story1 = { "WHEN  MARIO OPENED A",
	           "DOOR AFTER  CLIMBING",
	           "A LONG STAIR IN  HIS",
	           "DREAM, ANOTHER WORLD",
	           "SPREAD   BEFORE  HIM",
	           "AND HE HEARD A VOICE",
	           "CALL FOR HELP TO  BE",
	           " FREED  FROM A SPELL"
	         }

	story2 = { "AFTER  AWAKENING,   ",
	           "MARIO  WENT TO  A   ",
	           "CAVE  NEARBY AND  TO",
	           "HIS  SURPRISE HE SAW",
	           "EXACTLY  WHAT HE SAW",
	           "IN HIS DREAM***     ",
	           "                    ",
	           "  PUSH START BUTTON "
	         }
end

function loadLevel()
	leveldir = "levels/"..tostring(world).."-"..tostring(level).."/"
	levelfile = love.filesystem.read(leveldir.."settings.cfg")

	-- Get level variables
	allareas = tonumber(string.sub(levelfile, 7, 7))
	startx = tonumber(string.sub(levelfile, 16, 19))
	starty = tonumber(string.sub(levelfile, 28, 31))

	for i=0, allareas - 1 do
	-- Fill area width, height and background arrays
		areafile = love.filesystem.read(leveldir..tostring(area))

		diff = i * 38

		areawidth[i] = tonumber(string.sub(levelfile, 49 + diff, 52 + diff))
		areaheight[i] = tonumber(string.sub(levelfile, 61 + diff, 64 + diff))
		areabg[i] = tonumber(string.sub(levelfile, 69 + diff, 69 + diff))
		areamusic[i] = tonumber(string.sub(levelfile, 77 + diff, 77 + diff))
	end

	loadArea()
end

function loadArea()
	areafile = love.filesystem.read(leveldir..tostring(area))

	-- Check level background and set it
	if areabg[area] == 0 then
		love.graphics.setBackgroundColor(0, 0, 0)
	else
		love.graphics.setBackgroundColor(60, 180, 282)
	end

	playAreaMusic()

	for i=0, (areaheight[area] / 16) - 1 do
	-- Fill tile data
	areatiles[i] = {}
		for j=0, (areawidth[area] / 16) - 1 do
			diff = i * (((areawidth[area] / 16) * 3) + 1)

			areatiles[i][j] = tonumber(string.sub(areafile, (j * 3) + 1 + diff, (j * 3) + 2 + diff))
		end
	end

	--TODO: Add more!
end

function saveLevel()
	leveldir = "levels/"..tostring(world).."-"..tostring(level).."/"

	-- Convert startx and starty to string variables
	startx_str = toPaddedString(startx, 4)
	starty_str = toPaddedString(starty, 4)

	areadata = ""
	areawidth_str = {}
	areaheight_str = {}

	for i=0, allareas - 1 do
		-- Convert areawidths and areaheights to string variables
		areawidth_str[i] = toPaddedString(areawidth[i], 4)
		areaheight_str[i] = toPaddedString(areaheight[i], 4)

		areadata = areadata..i.." width="..areawidth_str[i].." height="..areaheight_str[i].." bg="..tostring(areabg[i]).." music="..tostring(areamusic[i]).."\n"
	end

	-- Save file with all variables
	data = "areas="..tostring(allareas).."\nstartx="..startx_str.."\nstarty="..starty_str.."\n\nareas:\n"..areadata
	levelfile = love.filesystem.write(leveldir.."settings.cfg", data)

	saveArea()

	--TODO: Add more!
end

function saveArea()
	areadir = "levels/"..tostring(world).."-"..tostring(level).."/"..tostring(area)

	areadata = ""

	for i=0, (areaheight[area] / 16) - 1 do
	-- Fill file
		for j=0, (areawidth[area] / 16) - 1 do
			areatiles_str = toPaddedString(areatiles[i][j], 2)

			areadata = areadata..areatiles_str.."."
		end

		areadata = areadata.."\n"
	end

	areafile = love.filesystem.write(areadir, areadata)
end

function playAreaMusic()
	if debugmute == false then
		if areamusic[area] == 0 then
			mus_overworld:play()

			mus_underworld:stop()
			mus_boss:stop()
		elseif areamusic[area] == 1 then
			mus_underworld:play()

			mus_overworld:stop()
			mus_boss:stop()
		else
			mus_boss:play()

			mus_overworld:stop()
			mus_underworld:stop()
		end
	end
end

function stopAreaMusic()
	mus_overworld:stop()
	mus_underworld:stop()
	mus_boss:stop()
end

function checkEditCursorBounds()
	if editcurx > areawidth[area] - 16 then
		editcurx = areawidth[area] - 16
	end

	if editcury > areaheight[area] - 16 then
		editcury = areaheight[area] - 16
	end
end

function checkEditGridBounds()
	if editcurx < editviewx then
		editviewx = editviewx - 16

	elseif editcurx == editviewx + 256 then
		editviewx = editviewx + 16
	end

	if editcury < editviewy then
		editviewy = editviewy - 16

	elseif editcury == editviewy + 208 then
		editviewy = editviewy + 16
	end
end

function placeTile(tileid)
	edittilex = editcurx / 16
	edittiley = editcury / 16
	areatiles[edittiley][edittilex] = tileid
end

function quitEditor()
	editoroption = 0

	editcurx = 0
	editcury = 0

	editviewx = 0
	editviewy = 0

	love.graphics.setBackgroundColor(0, 0, 0)

	stopAreaMusic()
end

function drawFont(str, x, y, color)
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

function drawTile(tileid, tilex, tiley)
	ax = (tileid % 16) * 16
	ay = math.floor(tileid / 16) * 16

	tile = love.graphics.newQuad(ax, ay, 16, 16, img_tiles:getWidth(), img_tiles:getHeight())

	love.graphics.draw(img_tiles, tile, tilex, tiley)
end

function transitionClear()
	transitiontimer = 0
	transition = false
end

function toPaddedString(number, digits)
	str = tostring(number)
	sum = number

	for i=1, digits - 1 do
		if sum < 10 then
			str = "0"..str
		end

		sum = sum / 10
	end

	return str
end