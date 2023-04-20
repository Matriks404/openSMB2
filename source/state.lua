local state = {}

-- Game state (launcher, title, intro, character_select, level_intro, gameplay, pause, death, game_over, editor, debug)
state.name = "launcher"

-- Timers
state.timer = 0
state.backup_timer = 0
state.text_timer = 0
state.transition_timer = 0
state.char_anim_timer = 0

state.screen_dir = 1 -- Direction to scroll (-1 is upwards, 1 is downwards)
state.transition = false

state.cursor = 0 -- Menu cursor

state.screen_x = 0
state.screen_y = 0

--TODO
function state.set(name)
	-- ...
end

function state.resetGame()
	world.reset()
	character.reset()
end

function state.verticalScreenTransition()
	if state.transition_timer == 35 then
		state.transition_timer = 0

		state.screen_y = state.screen_y + state.screen_dir
	else
		state.transition_timer = state.transition_timer + 1
	end
end

function state.transitionClear()
	state.transition_timer = 0
	state.transition = false
end

return state