
class Hotspot
  
  attr_accessor :name
  
  # Forces is a side-number indexed array indicating the
  # strength of forces in a given hotspot
  def initialize(hotspot_name)
    @name = hotspot_name
    @forces = []
  end
  
  def forces_for_side(side)
    return @forces.fetch(side, 0)
  end
  
end

class Map
  
  def initialize
    @hotspots = []
  end
  
end

class Player
  
  attr_accessor :side, :name
  
  def initialize(side_number, fancy_name)
    @side = side_number
    @name = fancy_name
  end
  
end