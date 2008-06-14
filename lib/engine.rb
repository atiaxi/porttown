require 'model'

require 'logger'
require 'yaml'
require 'singleton'

class MessageQueue
  
  def initialize
    @queue = []
  end
  
  def <<(msg)
    add_message(msg)
  end
  
  def add_message(msg)
    @queue << msg.as_message
  end
  
  def clear
    @queue.clear
  end
  
  def each(&proc)
    return @queue.each(&proc)
  end
  
  def update(delay)
    @queue.dup.each do | m |
      m.time -= delay
      @queue.delete(m) if m.time <= 0
    end
  end
  
end

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
  attr_reader :messages
  
  def initialize()
    flags = Rubygame::DOUBLEBUF | Rubygame::HWSURFACE
    @screen = Rubygame::Screen.new( [ 800, 600], 0, flags)
    @phases = []
    @images = {}
    @fonts = {}
    @current_phase_index = 0
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @messages = MessageQueue.new
  end
  
  def add_autoload(dir)
    Engine.autoload_dirs << dir unless Engine.autoload_dirs.include?(dir)
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
  
  def is_gem?(name)
    return @is_gem if @is_gem
    begin
      require 'rubygems'
      Gem.activate(name, false)
      @is_gem = true
    rescue LoadError
      @is_gem = false
    end
    return @is_gem
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
      self.update(phase,elapsed/1000.0)
      
      Rubygame::Clock.wait(200)
    end
    Rubygame::quit
  end
  
  def update(phase,delay)
    @messages.update(delay)
    phase.update(delay)
  end
  
  def yaml_for(filename)
    fullpath = Engine.find_file(filename)
    return YAML::load_file(fullpath)
  end
  
end