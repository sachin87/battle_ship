require_relative 'require_all'
 
class Game
   
  include EventHandler::HasEventHandler

  def initialize
    @your_details = {:ship_location => [], :ships_alive => 5, :attack_coordinates => []}
    @computer_details = {:ship_location => [], :ships_alive => 5, :attack_coordinates => []}
    make_screen
    make_clock
    make_queue
    make_event_hooks
    place_ships
  end

  def draw_playing_board(start_coordinates = [], ending_coordinates = [], colour = "white")
    @screen.draw_box start_coordinates, ending_coordinates, colour
  end

  def make_screen
    # Report the current dimensions of the desktop in pixels.  A fullscreen window
    # should be able to achieve at least this resolution.
    maximum_resolution = Screen.get_resolution
    puts "This display can manage at least " + maximum_resolution.join("x")
    # Open a double-buffered, video-RAM-based window in full-screen mode at the
    # maximum resolution
    default_depth = 0
    @screen = Screen.open([800,600],default_depth,[ HWSURFACE, DOUBLEBUF])
    @screen.title = "Battle ship--World War I"
    # Show the color depth of the screen
    puts "The screen has a color depth of %i bits" % @screen.depth
    # Hide the mouse cursor
    #@screen.show_cursor = false
    # Screen is a Surface, so all methods on Surface are available
    center = maximum_resolution.collect! {|axis| axis / 2}
    color = [ 0xc0, 0x80, 0x40]
    draw_playing_board([10,10],[210,210],'white')
    draw_playing_board([10,250],[210,450],'red')
    draw_playing_board([250,10],[450,210],'white')
    draw_playing_board([250,250],[450,450],'red')

    def cross_board(x=10,y=0,colour='white')
      x_dup = x
      y_dup = (y == 0 ? 10 : y)
      GRID_SIZE.times do
        @screen.draw_line [x +=20,y_dup], [x, (y==0 ? 10 : y_dup) + 200], colour
        @screen.draw_line [x_dup,(y == 0 ? x : y+=20)], [(x_dup == 10 ? 210 : 450),(y == 0 ? x : y)], colour
      end
    end

    cross_board(10,0,"white")
    cross_board(10,250,"red")
    cross_board(250,10,"white")
    cross_board(250,250,"red")
    
    # Show the changes to the screen surface by flipping the buffer that is visible
    # to the user.  All changes made to the screen surface will appear
    # simultaneously
    @screen.flip
  end

  
  # Create a new Clock to manage the game framerate
  # so it doesn't use 100% of the CPU
  def make_clock
    @clock = Clock.new()
    @clock.target_framerate = 50
    @clock.calibrate
    @clock.enable_tick_events
  end
 
 
  # Set up the event hooks to perform actions in
  # response to certain events.
  def make_event_hooks
    hooks = {
      :escape => :quit,
      :q => :quit,
      QuitRequested => :quit
    }
 
    make_magic_hooks( hooks )
  end
 
 
  # Create an EventQueue to take events from the keyboard, etc.
  # The events are taken from the queue and passed to objects
  # as part of the main loop.
  def make_queue
    # Create EventQueue with new-style events (added in Rubygame 2.4)
    @queue = EventQueue.new()
    @queue.enable_new_style_events
 
    # Don't care about mouse movement, so let's ignore it.
    @queue.ignore = [MouseMoved]
  end

  def create_ships
    i = 0
    loop do
      puts "Enter the cordinates to place the ship no #{i + 1}"
      input = gets.chomp
      if COORDINATES.include?(input)
        unless @your_details[:ship_location].include?(input)
          @your_details[:ship_location] << input
          x1,y1 = input.split("")
          x = 10 + X[x1]
          y = 250 + Y[y1]
          GRID_SIZE.times do
            @screen.draw_line [x, y +=2], [ x + 20,y], 'red'
          end
          @screen.flip
          i +=1
          break if i >= @your_details[:ships_alive]
        else
          puts "Already choosed this Coordinate"
        end
      else
        puts "This is not a valid Coordinate"
      end
    end
  end

  # Create the player ship in the middle of the screen
  def place_ships
    create_ships
    @computer_details[:ship_location] << COORDINATES.sample(5)
    p @computer_details[:ship_location]
    loop do
      i = 0
      loop do
        puts "Enter the no. #{i + 1} attack coordinate."
        input = gets.chomp
        if COORDINATES.include?(input)
          unless @computer_details[:attack_coordinates].include?(input)
            @your_details[:attack_coordinates] << input
            x1 = input[0]
            y1 = input[1]
            x = 250 + X[x1]
            y = 10 + Y[y1]
            @screen.draw_line [x,y], [x + 20,y + 20], 'red'
            @screen.draw_line [x + 20,y], [x,y + 20], 'red'
            @screen.flip
            i +=1
            @computer_details[:ships_alive] -= 1 if @computer_details[:ship_location].include?(input)
            break if i >= @your_details[:ships_alive]
          else
            puts "Already choosed this Coordinate"
          end
        else
          puts "This is not a valid Coordinate"
        end
      end

      puts "Now Computer Playing....." 
      inputs = (COORDINATES - @computer_details[:attack_coordinates]).sample(@computer_details[:ships_alive])
      inputs.each do |input| 
        @your_details[:attack_coordinates] << input
        x1 = input[0]
        y1 = input[1]
        x = 250 + X[x1]
        y = 250 + Y[y1]
        @screen.draw_line [x,y], [x + 20,y + 20], 'white'
        @screen.draw_line [x + 20,y], [x,y + 20], 'white'
        @your_details[:ships_alive] -= 1 if @your_details[:ship_location].include?(input)
        @screen.flip
      end
      p @computer_details[:ships_alive]
      if @computer_details[:ships_alive] == 0
        puts "YOU WON !!!!!"
        break
      elsif @your_details[:ships_alive] == 0
        puts "COMPUTER WON !!!!!"
        x1 = input[0]
        y1 = input[1]
        x = 10 + X[x1]
        y = 10 + Y[y1]
        10.times do
          @screen.draw_line [x, y +=2], [ x + 20,y], 'white'
        end
        @screen.flip
        break
      end
    end
    p @your_details
    gets
    #@ship = Ship.new( @screen.w/2, @screen.h/2 , 'red')
 
    # Make event hook to pass all events to @ship#handle().
    #make_magic_hooks_for( @ship, { YesTrigger.new() => :handle } )
  end


 
  # The "main loop". Repeat the #step method
  # over and over and over until the user quits.
  def go
    catch(:quit) do
      loop do
        step
      end
    end
  end

  # Quit the game
  def quit
    puts "Quitting!"
    throw :quit
  end
 
 
  # Do everything needed for one frame.
  def step
    # Clear the screen.
    @screen.fill( :black )
 
    # Fetch input events, etc. from SDL, and add them to the queue.
    @queue.fetch_sdl_events
 
    # Tick the clock and add the TickEvent to the queue.
    @queue << @clock.tick
 
    # Process all the events on the queue.
    @queue.each do |event|
      handle( event )
    end
 
    # Draw the ship in its new position.
    @ship.draw( @screen )
 
    # Refresh the screen.
    @screen.update()
  end

end 
