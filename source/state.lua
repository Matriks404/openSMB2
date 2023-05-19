local state = {}

state.delta = 0
state.tick_rate = 1 / 59.286

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

state.s = {}

function state.setupState(name, background, font, music)
	state.s[name] = { background = background, font = font, music = music }
end

function state.set(name)
	state.name = name
	state.timer = 0

	local s = state.s[name]

	if s.background ~= "LEVEL_SPECIFIC" then
		graphics.setBackgroundColor(s.background)
	end

	if s.music ~= "LEVEL_SPECIFIC" then
		game_resources.music.setCurrent(s.music)

		if not app.muted then
			game_resources.music.play()
		end
	end
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