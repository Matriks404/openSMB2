function love.load()
	gametitle = "openSMB2 v"..getVersion()

	-- Setting up window
	love.window.setMode(256, 240, {vsync = true}) -- 256x240 is a NES resolution
	love.window.setTitle(gametitle)
	love.filesystem.setIdentity("openSMB2")

	love.graphics.setBackgroundColor(0.36, 0.58, 0.99)

	-- Loading resources
	loadFonts()
	loadGraphics()
	loadMusic()
	loadSoundEffects()
	loadStory()

	state = 0 -- Game state (0 - title screen, 1 - intro, 2 - character select, 3 - level intro, 4 - gameplay, 5 - paused gameplay, 6 - dying screen, 7 - game over screen, 98 - level editor 99 - debug screen)

	-- Debugging variables
	debugmode = false
	debugfps = true
	debugframes = true
	debugmute = false

	-- Timers
	timer = 0
	texttimer = 0
	transitiontimer = 0
	backuptimer = 0
	dyingtimer = 0

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
	character = 0 -- Character (0 - Mario, 1 - Luigi, 2 - Toad, 3 - Princess Peach)
	continues = 2
	lifes = 3
	energy = 2
	energybars = 2
	charstate = 0 -- Character state (0 - Falling, 1 - Not falling)

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
	herosuby = 0 --TODO: Use it!

	heroside = 1 -- On which side character is looking at (-1 - Left, 1 - Right)
	heromovdir = 1 -- In which direction character is moving (-1 - Left, 1 - Right)
	herospeed = 0 -- Character speed
	heroaccel = 0 -- Character acceleration

	heroanimtimer = 0 -- Character animation timer
end

function love.update()
	timer = timer + 1

	if state == 0 then
	-- Title screen stuff
		mus_title:play()

		-- After some time go to intro story
		if timer == 500 then
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

				mus_charsel:stop()
				transitionClear()

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
		if heroy < screeny * 240 then
			screeny = screeny - 1

		elseif heroy > (screeny + 1 ) * 240 then
		-- Switching vertical screen downwards
			--TODO: Vertical screen scrolling
			screeny = screeny + 1
		end

		if screeny < 0 then
			screeny = 0

		elseif screeny > (areaheight[area] / 16 / 15) - 1 then
		-- Character is below lowest screen
				screeny = (areaheight[area] / 16 / 15) - 1 -- Keep lowest screen shown
				dyingtimer = dyingtimer + 1
		end

		if timer > 146 then
			-- Left/Right movement
			if love.keyboard.isDown("left") then
				heroside = -1

				if herospeed == 0 then
					heromovdir = -1
				end

				if heromovdir == 1 then
					herospeed = herospeed - 4
					heroaccel = heroaccel - 1
				else
					if heroaccel < 6 then
						heroaccel = heroaccel + 1
					end

					if love.keyboard.isDown("z") then
						herospeed = 6 * heroaccel
					else
						herospeed = 4 * heroaccel
					end
				end

			elseif love.keyboard.isDown("right") then
				heroside = 1

				if herospeed == 0 then
					heromovdir = 1
				end

				if heromovdir == -1 then
					herospeed = herospeed - 4
					heroaccel = heroaccel - 1
				else
					if heroaccel < 6 then
						heroaccel = heroaccel + 1
					end

					if love.keyboard.isDown("z") then
						herospeed = 6 * heroaccel
					else
						herospeed = 4 * heroaccel
					end
				end

			elseif herospeed > 0 then
			-- Reduce speed after time
				herospeed = herospeed - 4
				heroaccel = heroaccel - 1
			end

			if heroaccel < 0 then
			-- Reseting hero acceleration to 0
				heroaccel = 0
			end

			if herospeed > 0 then
				-- Calculating character position
				herosubx = herosubx + herospeed * heromovdir

				while herosubx >= 16 or herosubx <= -16 do
					herosubx = herosubx - 16 * heromovdir
					herox = herox + heromovdir
				end

				-- Horizontal character position wraping
				if herox > areawidth[area] then
					herox = 0 + herox % areawidth[area]

				elseif herox < 0 then
					herox = areawidth[area] + herox
				end

			elseif herospeed < 0 then
			-- Reset hero speed to 0
				herospeed = 0
			end

			heroy = heroy + 2 -- Falling --TEMPORARY

			if dyingtimer == 6 then
			-- Deplate energy and play death sound
				energy = 0

				stopAreaMusic()
				sfx_death:play()
			end

			if dyingtimer == 84 then
			-- Die!
				timer = 0
				dyingtimer = 0

				lifes = lifes - 1 -- Decrement a life

				if lifes > 0 then
				-- Going to death screen and playing once more
					energy = 2 -- Reset energy

					-- Reset character position and side
					herox = startx
					heroy = starty
					heroside = 1

					state = 6
				else
				-- No more lifes, go to game over screen
					sfx_gameover:play()

					if continues > 0 then
						cursor = 0
					else
						cursor = 1
					end

					state = 7
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
			transitionClear()

			if debugmute == false then
				mus_charsel:play()
			end

			-- Set up gameplay variables just after leaving title screen, as player will return to character select screen every completion of level.
			world = 1
			level = 1

			continues = 2
			lifes = 3
			energy = 2
			energybars = 2
			charstate = 0

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
	-- Gameplay screen
		if key == "s" and timer > 146 then
		-- Go to pause screen
			state = 5

			backuptimer = timer
			timer = 0
		end

		if debugmode == true then
			if key == "d" then
			-- Die!
				dyingtimer = 84

				stopAreaMusic()
			end
		end

	elseif state == 5 then
	-- Pause screen
		if key == "s" then
		-- Go back to gameplay
			state = 4

			timer = backuptimer -- Backup gameplay timer
		end

	elseif state == 7 then
	-- Game over screen
		if key == "a" and continues > 0 then
		-- Select option
			if cursor == 0 then
				cursor = 1
			else
				cursor = 0
			end
		end

		if key == "s" then
			if cursor == 0 then
				continues = continues - 1
				lifes = 3
				energy = 2

				mus_charsel:play()

				state = 2
			else
				love.graphics.setBackgroundColor(0.36, 0.58, 0.99)

				cursor = 0
				timer = 0
				state = 0
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

				love.graphics.setBackgroundColor(0.36, 0.58, 0.99)
			end

		elseif editoroption == 1 then
		-- Edit map option
			if key == "b" then
			-- Change background color
				if areabg[area] == 0 then
					areabg[area] = 1

					love.graphics.setBackgroundColor(0.24, 0.74, 0.99)
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

		drawText("!\"", 193, 72)
		drawText("#1988 NINTENDO", 72, 184)

	elseif state == 1 then
	-- Draw intro story stuff
		if timer > 34 then
			drawText("STORY", 112, 40)

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
					drawText(tostring(story1[i]), 48, 64 + ((i - 1) * 16))
				else
					drawText(tostring(story2[i]), 48, 64 + ((i - 1) * 16))
				end
			end
		end

	elseif state == 2 then
	-- Draw character select screen stuff
		love.graphics.draw(img_charselborder, 0, 0)

		drawText("PLEASE SELECT", 72, 80)
		drawText("PLAYER", 96, 96)

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

		drawText("EXTRA LIFE", 64, 208)
		drawText(remainingLifes(), 176, 208)

	elseif state == 3 then
		drawLevelbook() -- Draw levelbook

		drawWorldImage() -- Draw world image

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

			drawCharacter() -- Draw character on screen

			--TODO: Draw entities
		end

	elseif state == 5 then
	-- Draw pause screen stuff
		drawLevelbook() -- Draw levelbook

		-- Draw flickering pause text
		if transitiontimer == 30 then
			transitiontimer = 0

		elseif transitiontimer >= 15 then
			drawText("PAUSED", 105, 120, "brown")
		end

		drawText("EXTRA LIFE*** "..remainingLifes(), 65, 176, "brown") -- Draw extra lifes text

		transitiontimer = transitiontimer + 1

	elseif state == 6 then
	-- Draw dying screen stuff

		drawLevelbook() -- Draw levelbook

		drawText("EXTRA LIFE*** "..remainingLifes(), 65, 80, "brown") -- Draw remaining lifes

		drawWorldImage() -- Draw world image

		if timer >= 120 then
		-- Go to gameplay once again!
			state = 4
			timer = 0

			playAreaMusic()
		end

	elseif state == 7 then
	-- Draw game over screen stuff
		if timer < 192 then
			drawText("GAME  OVER", 88, 112)
		else
			-- Draw text
			if continues > 0 then
				drawText("CONTINUE "..tostring(continues), 96, 88)
			end

			drawText("RETRY", 96, 104)

			love.graphics.draw(img_indicator, 81, 89 + cursor * 16)
		end

	elseif state == 98 then
	-- Draw level editor stuff
		if editoroption == 0 then
		-- Draw level editor menu
			drawText("OPENSMB2 "..getVersion(), 32, 32)
			drawText("LEVEL EDITOR", 32, 48)

			drawText("LEVEL SELECT", 32, 80)

			drawText(" 1 - 1-1  4 - 2-1  7 - 3-1", 32, 96)
			drawText(" 2 - 1-2  5 - 2-2  8 - 3-2", 32, 112)
			drawText(" 3 - 1-3  6 - 2-3  9 - 3-3", 32, 128)

			drawText(" A - 4-1  D - 5-1  G - 6-1", 32, 160)
			drawText(" B - 4-2  E - 5-2  H - 6-2", 32, 176)
			drawText(" C - 4-3  F - 5-3  I - 6-3", 32, 192)

			drawText(" J - 7-1  K - 7-2  Q - QUIT", 32, 224)

		elseif editoroption == 1 then
		-- Draw editor
			-- Draw world, level and area indicators
			drawText(tostring(world).."-"..tostring(level), 64, 2)
			drawText("A-"..tostring(area), 104, 2)

			-- Draw background value
			if areabg[area] == 0 then
				drawText("BG-BLK", 144, 2)
			else
				drawText("BG-BLU", 144, 2)
			end

			-- Draw music indicator
			if areamusic[area] == 0 then
				drawText("M-OVER", 208, 2)
			elseif areamusic[area] == 1 then
				drawText("M-UNDR", 208, 2)
			else
				drawText("M-BOSS", 208, 2)
			end

			-- Draw width and height values
			drawText("W-"..tostring(areawidth[area]), 2, 10)
			drawText("H-"..tostring(areaheight[area]), 56, 10)

			-- Draw currently selected tile
			drawText("T-"..tostring(edittile), 120, 10)
			drawTile(edittile, 152, 10)

			-- Draw coordinates for edit cursor
			drawText(tostring(editcurx), 184, 10)
			drawText(",", 216, 10)
			drawText(tostring(editcury), 224, 10)

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
		drawText("OPENSMB2 DEBUG MODE", 48, 56)
		drawText("F-TOGGLE FPS COUNTER", 48, 80)
		drawText("R-TOGGLE FRAME COUNTER", 48, 96)
		drawText("M-TOGGLE MUSIC MUTE", 48, 112)
		drawText("L-ENTER LEVEL EDITOR", 48, 128)
		drawText("S-START GAME RIGHT NOW", 48, 144)

		drawText("ENABLED FLAGS", 64, 160)

		if debugfps == true then
			drawText("FPS", 64, 176)
		end

		if debugframes == true then
			drawText("FRAMES", 104, 176)
		end

		if debugmute == true then
			drawText("MUTED", 168, 176)
		end
	end

	-- Draw debug stuff
	if debugmode == true then
		-- Draw FPS
		if debugfps == true then
			drawText(tostring(love.timer.getFPS()).." FPS", 2, 2)
		end

		-- Draw lasted frames
		if debugframes == true then
			timerx = 0
			n = timer

			while n > 0 do
				timerx = timerx + 1
				n = math.floor(n / 10)
			end

			drawText(tostring(timer), 256 - (timerx * 8), 2)
		end
	end
end

function loadFonts()
	fontdir = "resources/images/font/" -- Fonts folder

	-- White and brown font graphics
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

	-- Character graphics
	imgch = "resources/images/gameplay/characters/"

	img_char_mario = love.graphics.newImage(imgch.."mario.png")
	img_char_luigi = love.graphics.newImage(imgch.."luigi.png")
	img_char_toad = love.graphics.newImage(imgch.."toad.png")
	img_char_peach = love.graphics.newImage(imgch.."peach.png")

	img_indicator = love.graphics.newImage("resources/images/indicator.png")
end

function loadMusic()
	musdir = "resources/sound/music/" -- Music folder

	mus_title = love.audio.newSource(musdir.."title.ogg", "stream")
	mus_charsel = love.audio.newSource(musdir.."charselect.ogg", "stream")
	mus_overworld = love.audio.newSource(musdir.."overworld.ogg", "stream")
	mus_underworld = love.audio.newSource(musdir.."underworld.ogg", "stream")
	mus_boss = love.audio.newSource(musdir.."boss.ogg", "stream")
end

function loadSoundEffects()
	sfxdir = "resources/sound/effects/" -- Sound effects folder

	sfx_cherry = love.audio.newSource(sfxdir.."cherry.ogg", "static")
	sfx_death = love.audio.newSource(sfxdir.."death.ogg", "static")
	sfx_gameover = love.audio.newSource(sfxdir.."gameover.ogg", "static")
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
		love.graphics.setBackgroundColor(0.24, 0.74, 0.99)
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

	edittile = 1

	editcurx = 0
	editcury = 0

	editviewx = 0
	editviewy = 0

	love.graphics.setBackgroundColor(0, 0, 0)

	stopAreaMusic()
end

function drawText(str, x, y, color)
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

function remainingLifes()
	if lifes < 10 + 1 then
		str = " "..tostring(lifes - 1)

	elseif lifes < 100 + 1 then
		str = tostring(lifes - 1)

	elseif lifes < 255 + 1 then
		if lifes < 110 + 1 then     letter = "A"
		elseif lifes < 120 + 1 then letter = "B"
		elseif lifes < 130 + 1 then letter = "C"
		elseif lifes < 140 + 1 then letter = "D"
		elseif lifes < 150 + 1 then letter = "E"
		elseif lifes < 160 + 1 then letter = "F"
		elseif lifes < 170 + 1 then letter = "G"
		elseif lifes < 180 + 1 then letter = "H"
		elseif lifes < 190 + 1 then letter = "I"
		elseif lifes < 200 + 1 then letter = "J"
		elseif lifes < 210 + 1 then letter = "K"
		elseif lifes < 220 + 1 then letter = "L"
		elseif lifes < 230 + 1 then letter = "M"
		elseif lifes < 240 + 1 then letter = "N"
		elseif lifes < 250 + 1 then letter = "O"
		else                        letter = "P"
		end

		str = letter..tostring(math.floor((lifes - 1) % 10))
	end

	return str
end

function drawLevelbook()
	love.graphics.draw(img_levelbook, 25, 32)

	drawText("WORLD  "..tostring(world).."-"..tostring(level), 89, 48, "brown")

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
end

function drawWorldImage()
	if world == 1 or world == 3 or world == 5 then love.graphics.draw(img_lb_1, 65, 112)
	elseif world == 2 or world == 6 then           love.graphics.draw(img_lb_2, 65, 112)
	elseif world == 4 then                         love.graphics.draw(img_lb_4, 65, 112)
	elseif world == 7 then                         love.graphics.draw(img_lb_7, 65, 112)
	end
end

function drawCharacter()
	-- Calculate offset for character sprite
	if heroside == -1 then
		offset = 16

	elseif heroside == 1 then
		offset = 0
	end

	-- Calculate desired character sprite
	if charstate == 1 then
	-- Calculate sprite if character is walking
		if herospeed > 0 then
			if heroanimtimer >= 10 then
				heroanimtimer = 0
			end

			if heroanimtimer >= 5 then
				ax = 0 * 16
			else
				ax = 1 * 16
			end

			heroanimtimer = heroanimtimer + 1
		else
			ax = 0 * 16

			heroanimtimer = 0
		end
	elseif character == 1 and charstate == 0 then
	-- Calculate sprite if character is Luigi and falling
		if heroanimtimer >= 6 then
			heroanimtimer = 0
		end

		if heroanimtimer >= 3 then
			ax = 0 * 16
		else
			ax = 1 * 16
		end

		heroanimtimer = heroanimtimer + 1
	else
		ax = 1 * 16

		heroanimtimer = 0
	end

	posy = heroy - screeny * 240

	-- Draw character sprite
	if character == 0 then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_char_mario:getWidth(), img_char_mario:getHeight())

		love.graphics.draw(img_char_mario, sprite, herox, posy, 0, heroside, 1, offset)

	elseif character == 1 then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_char_luigi:getWidth(), img_char_luigi:getHeight())

		love.graphics.draw(img_char_luigi, sprite, herox, posy, 0, heroside, 1, offset)

	elseif character == 2 then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_char_luigi:getWidth(), img_char_luigi:getHeight())

		love.graphics.draw(img_char_toad, sprite, herox, posy, 0, heroside, 1, offset)

	elseif character == 3 then
		sprite = love.graphics.newQuad(ax, 0, 16, 32, img_char_peach:getWidth(), img_char_peach:getHeight())

		love.graphics.draw(img_char_peach, sprite, herox, posy, 0, heroside, 1, offset)
	end

	-- Draw character sprite when it's horizontally wraping
	if herox > 256 - 16 then
		if character == 0 then
			love.graphics.draw(img_char_mario, sprite, herox - areawidth[area], posy, 0, heroside, 1, offset)

		elseif character == 1 then
			love.graphics.draw(img_char_luigi, sprite, herox - areawidth[area], posy, 0, heroside, 1, offset)

		elseif character == 2 then
			love.graphics.draw(img_char_toad, sprite, herox - areawidth[area], posy, 0, heroside, 1, offset)

		elseif character == 3 then
			love.graphics.draw(img_char_peach, sprite, herox - areawidth[area], posy, 0, heroside, 1, offset)
		end
	end
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

function getVersion()
	verfile = love.filesystem.read("version")

	return verfile
end