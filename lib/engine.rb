require 'logger'

class Phase
  
  def initialize(engine)
    @driver = engine
  end
  
  def click(loc)
    
  end
  
  def draw(screen)
    
  end
  
  def update(delay)
    
  end
  
end

class Engine
  
  include Rubygame::NamedResource
  
  IMAGES_DIR = "./images"
  DATA_DIR = "./data"
  Engine.autoload_dirs = [ IMAGES_DIR, DATA_DIR ]
  
  attr_reader :screen
  attr_reader :dirs
  attr_reader :logger
  
  def initialize(screen)
    @screen = screen
    @phases = []
    @images = {}
    @current_phase_index = 0
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end
  
  def current_phase
    return nil if @phases.empty?
    return @phases[@current_phase_index]
  end
  
  # Current phase calls this when it's all done
  def done
    return nil if @phases.empty?
    @current_phase_index = (@current_phase_index + 1) % @phases.size
  end
  
  def image_for(filename, auto_colorkey=true, auto_convert=true)
    return nil unless filename
    unless @images.has_key?(filename)
      begin
        fullpath = find_file(filename)
        img = Rubygame::Surface.load(fullpath)
      rescue Rubygame::SDLError
        @logger.fatal("Error loading '#{filename}': #{$!}")
      end
      img = img.convert if auto_convert
      @images[filename] = img
      if auto_colorkey
        img.set_colorkey( img.get_at( [0,0] ))
      end
    end
    return @images[filename]
  end 
  
  def run
    @running = true
    clock = Rubygame::Clock.new
    queue = Rubygame::EventQueue.new
    
    clock.tick
    phase = current_phase
    while @running && phase
      queue.each do | event |
        case(event)
        when Rubygame::QuitEvent
          @running = false
        # TODO: More event handling
        when Rubygame::MouseUpEvent
          phase.click(event.pos)
        end
      end
      
      @screen.fill(Rubygame::Color[:black])
      # TODO: Draw screen
      @screen.flip
      elapsed = clock.tick
      # TODO: Updates
      
      Rubygame::Clock.wait(0.05)
    end
    Rubygame::quit
  end
  
end