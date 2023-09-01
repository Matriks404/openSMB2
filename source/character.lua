local character = {}

character.dying_timer = 0

-- Character position
character.pos_x = 0
character.pos_y = 0

function character.reset()
	character.subpos_x = 0 -- Character position subpixels --TODO: Character x and y positions should just be multiplied by 256, we don't need that variable.

	character.current = "char1" -- Character (char1, char2, char3, char4)
	character.continues = 2
	character.lives = 3
	character.energy = 2
	character.energy_bars = 2
	character.state = "falling" -- Character state (falling, stationary)

	-- Character orientation and movement
	character.side = 1 -- On which side character is looking at (-1 - Left, 1 - Right)
	character.has_controlled_movement = false
	character.is_ascending = false
	character.is_running = false
	character.movement_dir = 1 -- In which direction character is moving (-1 - Left, 1 - Right)
	character.speed = 0
	character.accel = 0
end

return character