# We define all our constants here.

# set of coordinates that are avalable in game for a user to select
COORDINATES = ('a0'..'j9').to_a

GRID_SIZE = 10

# mapping of above cordinates to a specific value.
# Example if a user select 'a0'
# then x = 'a0'[0]
# then y = 'a0'[1]
# then we need to mark the square starting.
X = { 'a' => 0 , 'b' => 20, 'c' => 40, 'd' => 60, 'e' => 80, 'f' => 100, 'g' => 120, 'h' => 140, 'i' => 160, 'j' => 180}
Y = { '0' => 0 , '1' => 20, '2' => 40, '3' => 60, '4' => 80, '5' => 100, '6' => 120, '7' => 140, '8' => 160, '9' => 180}
