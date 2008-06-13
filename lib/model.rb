
class Hotspot
  
  attr_accessor :name
  attr_accessor :base
  attr_accessor :x
  attr_accessor :y
  
  attr_reader :connected_to
  # Forces is a side-number indexed array indicating the
  # strength of forces in a given hotspot
  def initialize(hotspot_name)
    @name = hotspot_name
    @spawnpoint = nil
    @forces = []
    @connected_to = []
    @x = 0
    @y = 0
  end
  
  def base_of(player)
    @base = player.side
  end
  
  def base_of?(player)
    return @base == player.side
  end
  
  def connect_to(hotspot)
    @connected_to << hotspot unless @connected_to.include?(hotspot)
    hotspot.connect_to(self) unless hotspot.connected_to.include?(self)
  end
  
  def forces_for(player)
    return @forces.fetch(player.side, 0)
  end
  
  def loc=(anArray)
    @x,@y = anArray
  end
  
  def reinforce(player, amount)
    initial = forces_for(player)
    @forces[player.side] = initial+amount
  end
  
end

class Map
  
  attr_reader :players
  attr_reader :hotspots
  
  def initialize
    @hotspots = []
    @players = []
  end
  
  def active_players
    return @players.select { |p| p.controller != :neutral }
  end
  
  def add_hotspot(spot)
    @hotspots << spot unless @hotspots.include?(spot)
  end
  
  def add_player(player)
    @players[player.side] = player
  end
  
end

class Player
  
  attr_accessor :side, :name
  
  # One of :person, :cpu, or :neutral - neutral is like CPU except they don't
  # get a placement phase and don't do anything.
  attr_accessor :controller
  
  def initialize(side_number, fancy_name, control=:person)
    @side = side_number
    @name = fancy_name
    @controller = control
  end
  
end