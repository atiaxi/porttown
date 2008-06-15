# This file is part of Port Town.
#
# Port Town is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

require 'model'

require 'logger'
require 'yaml'
require 'singleton'

begin
  require 'rubygems'
  gem 'rubygame', '>=2.3.0'
rescue LoadError
  # Either no gems or no rubygame
end

begin
  require 'rubygame'
rescue LoadError
  puts "This game requires Rubygame 2.3.0 or better"
  exit
end

require 'message'

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
  
  def hover(loc)
    
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
    @screen = nil
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
      # Apparently Gem.activate changed from 2 args to 1 at some point, and I
      # can't find rdocs anywhere that tell me why, so this is a workaround
      begin
        Gem.activate(name)
      rescue ArgumentError
        Gem.activate(name, false)
      end  
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
        when Rubygame::MouseMotionEvent
          phase.hover(event.pos)
        end
      end
      
      elapsed = clock.tick
      self.update(phase,elapsed/1000.0)
      
      screen.fill(Rubygame::Color[:black])
      phase.draw(screen)
      screen.flip
      
      Rubygame::Clock.wait(200)
    end
    Rubygame::quit
  end
  
  def screen
    return @screen if @screen
    flags = Rubygame::DOUBLEBUF | Rubygame::HWSURFACE
    @screen = Rubygame::Screen.new( [ 800, 600], 0, flags)
    return @screen
  end
  
  def update(phase,delay)
    @messages.update(delay)
    phase.update(delay)
  end
  
  def yaml_for(filename)
    fullpath = Engine.find_file(filename)
    if fullpath
      return YAML::load_file(fullpath)
    else
      @logger.fatal("Unable to locate: #{filename}")
      return nil
    end
  end
  
end