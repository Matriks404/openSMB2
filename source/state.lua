local state = {}

-- Additional timers
state.backup_timer = 0
state.text_timer = 0
state.transition_timer = 0
state.char_anim_timer = 0

state.screen_dir = 1 -- Direction to scroll (-1 is upwards, 1 is downwards)
state.transition = false

state.cursor = 0 -- Menu cursor

state.screen_x = 0
state.screen_y = 0

state.s = {}

function state.setupState(name, bg, font, music)
	state.s[name] = { bg = bg, font = font, music = music }
end

function state.set(name)
	state.name = name
	state.timer = 0

	local s = state.s[name]

	if s.bg ~= "LEVEL_SPECIFIC" then
		graphics.setBackgroundColor(s.bg)
	end

	game_resources.music.playCurrent()
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