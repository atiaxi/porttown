
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
    amount = forces_for(player)
    limit = player.spawn_limit
    return false if limit && amount >= limit
    return true if base_of?(player)
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
  
  attr_accessor :background
  
  def initialize
    @hotspots = []
    @players = []
    @background = nil
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
  
  # The map is automated if every active player is a CPU player
  def automated
    return !active_players.detect { |player| player.controller != :cpu }
  end

  # Returns the first available spawning point, or nil
  def can_spawn_anywhere?(player)
    return @hotspots.detect { |s| s.can_spawn_here?(player) }
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
  
  # All the players controlled by :neutral
  def neutral_players
    return @players.select { |p| p.controller == :neutral }
  end
  
  # The opponents of the given player - all active players other than this one.
  def other_players(player)
    return @players.reject do |p|
      p == player || p.controller == :neutral
    end
  end
  
  # This only works if the array hasn't changed
  def player_on_side(side)
    return @players[side]
  end
  
  # If there is only one active player left, returns that.  Otherwise, nil.
  def winner
    active = active_players
    return active[0] if active.size == 1
    return nil
  end
  
end

class Player
  
  attr_accessor :description
  
  attr_accessor :side, :name
  attr_accessor :spawn_roll
  attr_accessor :number_to_spawn
  attr_accessor :dice_to_roll
  
  # One of :person, :cpu, or :neutral - neutral is like CPU except they don't
  # get a placement phase and don't do anything.
  attr_accessor :controller
  
  # If non-nil, for every this many civilians, we get one of us.
  attr_accessor :loot_threshold
  
  # If true, we do combat against civilians.  If we win, we convert one of them.
  # We only get to do the fight once per round, regardless of how many of us
  # there are.
  attr_accessor :lethal_conversion
  
  # The maximum number of our people we can have at any one hotspot
  # The default, nil, means no limit.
  attr_accessor :spawn_limit
  
  def initialize(side_number, fancy_name, control=:person)
    @side = side_number
    @name = fancy_name
    @controller = control
    @spawn_roll = 0
    @number_to_spawn = 0
    @dice_to_roll = 0
    @loot_threshold = nil
    @lethal_conversion = false
    @description = "civilian"
    @spawn_limit = nil
  end
  
  def ==(other)
    return @side == other.side
  end
  
  def can_spawn?
    return @number_to_spawn > 0
  end
  
  # Does a fight against the given other player, returns the victor
  # or nil on a tie
  def fight(other)
    result = roll(@dice_to_roll)
    our_roll = result.max
    their_roll = roll(other.dice_to_roll).max
    if our_roll > their_roll
      return self
    elsif their_roll > our_roll
      return other
    else
      return nil
    end
  end
  
end