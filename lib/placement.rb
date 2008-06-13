
class MapView
  
  def initialize(size = Rubygame::Rect.new(0, 100, 800, 400))
    @rect = size
  end
  
  def draw(screen)
    
  end
  
end

class PlacementPhase < Phase
  
  def initialize(engine, forPlayer)
    super
    @player = forPlayer
  end
  
  def draw(screen)
    screen.fill(Rubygame::Color[:red])
  end
  
end