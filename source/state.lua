local state = {}

-- Game state (title, intro, character_select, level_intro, gameplay, pause, death, game_over, editor, debug)
state.name = "title"

-- Timers
state.timer = 0
state.backup_timer = 0
state.text_timer = 0
state.transition_timer = 0
state.char_anim_timer = 0

state.transition = false

state.cursor = 0 -- Menu cursor

state.screen_x = 0
state.screen_y = 0

function state.resetGame()
	world.reset()
	character.reset()
end

function state.verticalScreenTransition()
	if state.transition_timer == 35 then
		state.transition_timer = 0

		state.screen_y = state.screen_y + screendir
	else
		state.transition_timer = state.transition_timer + 1
	end
end

function state.transitionClear()
	state.transition_timer = 0
	state.transition = false
end

return state