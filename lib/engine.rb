
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
  
  attr_reader :screen
  
  def initialize(screen)
    @screen = screen
    @phases = []
    @current_phase_index = 0
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