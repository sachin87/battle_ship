# This is the battle-ship game
 
require 'rubygems'
require 'rubygame'


# Import the Rubygame module into the current namespace, so that "Screen" may
# be referred directly instead of having to write "Rubygame::Screen"
include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers


class Ship
  include Sprites::Sprite
  include EventHandler::HasEventHandler
 
 
  def initialize( px, py, ship_colour = 'white' )
    @px, @py = px, py # Current Position
    @vx, @vy = 0, 0 # Current Velocity
    @ax, @ay = 0, 0 # Current Acceleration
 
    @max_speed = 400.0 # Max speed on an axis
    @accel = 1200.0 # Max Acceleration on an axis
    @slowdown = 800.0 # Deceleration when not accelerating
 
    @keys = [] # Keys being pressed
 
 
    # The ship's appearance. A white square for demonstration.
    @image = Surface.new([20,20])
    @image.fill(ship_colour.to_sym)
    @rect = @image.make_rect
 
 
    # Create event hooks in the easiest way.
    make_magic_hooks(
 
      # Send keyboard events to #key_pressed() or #key_released().
      KeyPressed => :key_pressed,
      KeyReleased => :key_released,
 
      # Send ClockTicked events to #update()
      ClockTicked => :update
 
    )
  end
 
 
  private
 
 
  # Add it to the list of keys being pressed.
  def key_pressed( event )
    @keys += [event.key]
  end
 
 
  # Remove it from the list of keys being pressed.
  def key_released( event )
    @keys -= [event.key]
  end
 
 
  # Update the ship state. Called once per frame.
  def update( event )
    dt = event.seconds # Time since last update
 
    update_accel
    update_vel( dt )
    update_pos( dt )
  end
 
 
  # Update the acceleration based on what keys are pressed.
  def update_accel
    x, y = 0,0
 
    x -= 1 if @keys.include?( :left )
    x += 1 if @keys.include?( :right )
    y -= 1 if @keys.include?( :up ) # up is down in screen coordinates
    y += 1 if @keys.include?( :down )
 
    # Scale to the acceleration rate. This is a bit unrealistic, since
    # it doesn't consider magnitude of x and y combined (diagonal).
    x *= @accel
    y *= @accel
 
    @ax, @ay = x, y
  end
 
 
  # Update the velocity based on the acceleration and the time since
  # last update.
  def update_vel( dt )
    @vx = update_vel_axis( @vx, @ax, dt )
    @vy = update_vel_axis( @vy, @ay, dt )
  end
 
 
  # Calculate the velocity for one axis.
  # v = current velocity on that axis (e.g. @vx)
  # a = current acceleration on that axis (e.g. @ax)
  #
  # Returns what the new velocity (@vx) should be.
  #
  def update_vel_axis( v, a, dt )
 
    # Apply slowdown if not accelerating.
    if a == 0
      if v > 0
        v -= @slowdown * dt
        v = 0 if v < 0
      elsif v < 0
        v += @slowdown * dt
        v = 0 if v > 0
      end
    end
 
    # Apply acceleration
    v += a * dt
 
    # Clamp speed so it doesn't go too fast.
    v = @max_speed if v > @max_speed
    v = -@max_speed if v < -@max_speed
 
    return v
  end
 
 
  # Update the position based on the velocity and the time since last
  # update.
  def update_pos( dt )
    @px += @vx * dt
    @py += @vy * dt
 
    @rect.center = [@px, @py]
  end
 
end
