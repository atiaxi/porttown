
class Hotspot
  
  attr_accessor :name
  attr_accessor :base
  attr_accessor :x
  attr_accessor :y
  
  attr_reader :connected_to
  # Forces is a side-number indexed array indicating the
  # strength of forces in a given hotspot
  attr_reader :forces
  
  def initialize(hotspot_name)
    @name = hotspot_name
    @spawnpoint = nil
    @forces = []
    @connected_to = []
    @x = 0
    @y = 0
    @base = nil
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
  
  def eliminate(player)
    @forces[player.side] = 0
  end
  
  def forces_for(player)
    val = @forces[player.side]
    val = 0 unless val
    return val
  end
  
  def loc=(anArray)
    @x,@y = anArray
  end
  
  # Attrit is the verb form of 'attrition'.  It's a real word!
  def attrit(player, amount)
    initial = forces_for(player)
    @forces[player.side] = [initial-amount, 0].max
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
  
  # This player is finished, mark them eliminated.
  def eliminate_player(player)
    player.controller = :neutral
    @hotspots.each do | spot |
      spot.eliminate(player)
    end
  end
  
  # If there are more of any one other player at your base then your own people,
  # then you lose
  def eliminate_player?(player)
    base = @hotspots.detect do | spot |
      spot.base_of?(player)
    end
    our_forces = base.forces_for(player)
    
    their_forces = other_players(player).collect { |p| base.forces_for(p) }
    return false if their_forces.size == 0
    return their_forces.max > our_forces
  end
  
  def hotspot_by_name(name)
    return @hotspots.detect { |spot| spot.name == name }
  end
  
  # The opponents of the given player - all active players other than this one.
  def other_players(player)
    return @players.reject do |p|
      p == player || p.controller == :neutral
    end
  end
  
  # If there is only one active player left, returns that.  Otherwise, nil.
  def winner
    active = active_players
    return active[0] if active.size == 1
    return nil
  end
  
end

class Player
  
  attr_accessor :side, :name
  attr_accessor :spawn_roll
  attr_accessor :number_to_spawn
  attr_accessor :dice_to_roll
  
  # One of :person, :cpu, or :neutral - neutral is like CPU except they don't
  # get a placement phase and don't do anything.
  attr_accessor :controller
  
  def initialize(side_number, fancy_name, control=:person)
    @side = side_number
    @name = fancy_name
    @controller = control
    @spawn_roll = 0
    @number_to_spawn = 0
    @dice_to_roll = 0
  end
  
  def ==(other)
    return @side == other.side
  end
  
end