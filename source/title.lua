local title = {}

function title.reset()
	state.timer = 0
	state.text_timer = 0
	game_resources.story.lines = 0
	game_resources.story.page = 1

	state.transitionClear()

	game_resources.music.restart()
end

function title.update()
	if state.transition then
		state.transition_timer = state.transition_timer + 1

		-- After some time after showing all story pages go to title screen again
		if state.transition_timer == 442 then
			title.reset()
		end

	elseif state.timer >= 553 then
		title.updateIntro()
	end
end

function title.updateIntro()
	if state.text_timer == 65 then
		game_resources.story.lines = game_resources.story.lines + 1
		state.text_timer = 0

		if game_resources.story.lines > 8 then
			if game_resources.story.page == #game_resources.story then
			-- Enable transition which will go to title screen after some time
				game_resources.story.lines = 8
				state.transition = true

			else
			-- Change to the next story page if all lines are displayed
				game_resources.story.lines = 0
				game_resources.story.page = game_resources.story.page + 1
				state.text_timer = 2
			end
		end
	end

	state.text_timer = state.text_timer + 1
end

function title.draw()
	-- Draw border on title screen and intro
	if game_resources.images.title_border then
		love.graphics.draw(game_resources.images.title_border, 0, 0)
	end

	if state.timer <= 500 then
		if game_resources.images.title_logo then
			love.graphics.draw(game_resources.images.title_logo, 48, 48)
		end

		-- Draw custom title screen text.
		if game.title_text then
			for i = 1, #game.title_text do
				local x = game.title_text[i]["x"]
				local y = game.title_text[i]["y"]
				local str = game.title_text[i]["string"]

				graphics.drawText(str, x, y)
			end
		end

	elseif state.timer >= 553 then
		graphics.drawText("STORY", 112, 40)

		for i = 1, game_resources.story.lines do
			local page = game_resources.story.page
		-- Draw lines of text
			graphics.drawText(tostring(game_resources.story[page][i]), 48, 64 + ((i - 1) * 16))
		end
	end
end

return title