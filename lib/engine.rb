require 'model'

require 'logger'
require 'yaml'
require 'singleton'

class Phase
  
  def initialize()
    @engine = Engine.instance
    @widgets = []
  end
  
  def activate
    
  end
  
  def click(loc)
    
  end
  
  def draw(screen)
    @widgets.each { |w| w.draw(screen) }
  end
  
  def update(delay)
    
  end
  
end

class Engine
  include Singleton
  include Rubygame::NamedResource
  
  IMAGES_DIR = "./images"
  DATA_DIR = "./data"
  Engine.autoload_dirs = [ IMAGES_DIR, DATA_DIR ]
  
  attr_reader :screen
  attr_reader :dirs
  attr_reader :logger
  
  def initialize()
    flags = Rubygame::DOUBLEBUF | Rubygame::HWSURFACE
    @screen = Rubygame::Screen.new( [ 800, 600], 0, flags)
    @phases = []
    @images = {}
    @fonts = {}
    @current_phase_index = 0
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end
  
  def add_phase(phase)
    @phases << phase
  end
  
  def add_phases(anArray)
    @phases += anArray
  end
  
  
  def current_phase
    return nil if @phases.empty?
    return @phases[@current_phase_index]
  end
  
  # Current phase calls this when it's all done
  def done
    return nil if @phases.empty?
    @current_phase_index = (@current_phase_index + 1) % @phases.size
    current_phase.activate if current_phase
  end
  
  def font_for(filename, size=16)
    data = [filename, size]
    return @fonts[data] if @fonts.has_key?(data)
    
    fullpath = Engine.find_file(filename)
    result = Rubygame::TTF.new(fullpath, size)
    @fonts[data] = result
    return result
  end
  
  def image_for(filename, auto_colorkey=true, auto_convert=true)
    return nil unless filename
    unless @images.has_key?(filename)
      begin
        fullpath = Engine.find_file(filename)
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
    current_phase.activate if current_phase
    while @running && current_phase
      phase = current_phase
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
      phase.draw(@screen)
      @screen.flip
      elapsed = clock.tick
      phase.update(elapsed / 1000.0)
      
      Rubygame::Clock.wait(200)
    end
    Rubygame::quit
  end
  
  def yaml_for(filename)
    fullpath = Engine.find_file(filename)
    return YAML::load_file(fullpath)
  end
  
end