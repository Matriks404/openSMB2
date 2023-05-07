local state = {}

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

state.s = {
	["launcher"] = { bg = "black", music = nil },
	["title"] = { bg = "blue", music = "title" },
	["intro"] = { bg = "blue", music = "title" },
	["character_select"] = { bg = "black", music = "character_select" },
	["level_intro"] = { bg = "black", music = nil },
	["gameplay"] = { bg = "OVERRIDE", music = "OVERRIDE" },
	["pause"] = { bg = "black", music = "OVERRIDE" },
	["death"] = { bg = "black", music = nil },
	["game_over"] = { bg = "black", music = nil },
	["level_editor"] = { bg = "black", music = nil },
}

function state.set(name)
	state.name = name
	state.timer = 0

	local s = state.s[name]

	if s.bg ~= "OVERRIDE" then
		graphics.setBackgroundColor(s.bg)
	end

	if s.music then
		if s.music and s.music ~= "OVERRIDE" then
			game_resources.music.play(s.music)
		end
	else
		game_resources.music.stopAll()
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