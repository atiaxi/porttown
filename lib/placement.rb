
class PlacementPhase < Phase
  
  def initialize(engine)
    super
    
  end
  
  def draw(screen)
    screen.fill(Rubygame::Color[:red])
  end
  
end