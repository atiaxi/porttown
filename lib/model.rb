
class Hotspot
  
  attr_accessor :name
  attr_accessor :base
  
  attr_reader :connected_tp
  # Forces is a side-number indexed array indicating the
  # strength of forces in a given hotspot
  def initialize(hotspot_name)
    @name = hotspot_name
    @spawnpoint = nil
    @forces = []
    @connected_to = []
  end
  
  def base_of_side?(side)
    return @base == side
  end
  
  def forces_for_side(side)
    return @forces.fetch(side, 0)
  end
  
end

class Map
  
  def initialize
    @hotspots = []
    @players = []
  end
  
  def add_player(player)
    @players[player.side] = player
  end
  
end

class Player
  
  attr_accessor :side, :name
  
  def initialize(side_number, fancy_name)
    @side = side_number
    @name = fancy_name
  end
  
end