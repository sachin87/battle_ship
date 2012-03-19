require_relative 'game'

# Start the main game loop. It will repeat forever
# until the user quits the game!
Game.new.go
 
 
# Make sure everything is cleaned up properly.
Rubygame.quit()
