local character = {}

character.dying_timer = 0

character.pos_x = 0
character.pos_y = 0
character.subpos_x = 0 -- Character position subpixels --TODO: Character x and y positions should just be multiplied by 256, we don't need that variable.

character.side = 1 -- On which side character is looking at (-1 - Left, 1 - Right)
character.movement_dir = 1 -- In which direction character is moving (-1 - Left, 1 - Right)
character.speed = 0
character.accel = 0 -- Character acceleration

function character.reset()
	character.current = "mario" -- Character (mario, luigi, toad, peach)
	character.continues = 2
	character.lives = 3
	character.energy = 2
	character.energy_bars = 2
	character.state = "falling" -- Character state (falling, stationary)
end

return character