local title = {}

title.story = {}
title.story.line = 1
title.story.page = 1

title.show_intro = true

function title.reset()
	state.resetTimer()

	state.text_timer = 0
	title.story.line = 1
	title.story.page = 1

	state.transitionClear()

	music.restart()
end

function title.update()
	title.show_intro = #title.story > 0

	if not title.show_intro then
		return
	end

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
	local max_pages = #title.story

	if state.text_timer == 65 then
		state.text_timer = 0

		title.story.line = title.story.line + 1
		local max_lines = #title.story[title.story.page]

		--TODO: We probably should allow more, maybe even with scrolling text if it's too long?
		if max_lines > 8 then
			max_lines = 8
		end

		if title.story.line > max_lines then
			if title.story.page == max_pages then
			-- Enable transition which will go to title screen after some time
				title.story.line = max_lines
				state.transition = true

			else
			-- Change to the next story page if all lines are displayed
				title.story.line = 0
				title.story.page = title.story.page + 1
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

	if not title.show_intro or state.timer <= 500 then
		if game_resources.images.title_logo then
			love.graphics.draw(game_resources.images.title_logo, 48, 48)
		end

		-- Draw custom title screen text.
		if game.title_text then
			for i = 1, #game.title_text do
				local x = game.title_text[i].x
				local y = game.title_text[i].y
				local str = game.title_text[i].string

				graphics.drawText(str, x, y)
			end
		end

	elseif state.timer >= 553 then
		graphics.drawText("STORY", 112, 40)

		local page = title.story.page
		local story_text = title.story[page]

		for i = 1, title.story.line do
		-- Draw lines of text
			graphics.drawText(tostring(story_text[i]), 48, 64 + ((i - 1) * 16))
		end
	end
end

return title