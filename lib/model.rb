
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
  
  def can_spawn_here?(player)
    return true if forces_for(player) > 0
    return @connected_to.detect do | spot |
      spot.forces_for(player) > 0
    end
  end
  
  def connect_to(hotspot)
    @connected_to << hotspot unless @connected_to.include?(hotspot)
    hotspot.connect_to(self) unless hotspot.connected_to.include?(self)
  end
  
  def forces_for(player)
    val = @forces[player.side]
    val = 0 unless val
    return val
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
  attr_accessor :spawn_roll
  attr_accessor :number_to_spawn
  
  # One of :person, :cpu, or :neutral - neutral is like CPU except they don't
  # get a placement phase and don't do anything.
  attr_accessor :controller
  
  def initialize(side_number, fancy_name, control=:person)
    @side = side_number
    @name = fancy_name
    @controller = control
    @spawn_roll = 0
    @number_to_spawn = 0
  end
  
end