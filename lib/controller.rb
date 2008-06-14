
class Message
  
  include Comparable
  
  attr_accessor :time
  attr_accessor :msg
  
  def initialize(message, display_for=2.0)
    @msg = message
    @time = display_for
  end
  
  def <=>(other)
    return self.time <=> other.time
  end
  
  def as_message
    return self
  end
  
  def to_s
    return msg
  end
  
end

class String
  def as_message
    return Message.new(self)
  end
end

class TurnController
  
  attr_reader :rolled
  
  def self.instance_for(player,map)
    case(player.controller)
    when :person
      return HumanController.new(player,map)
    when :cpu
      return AIController.new(player,map)
    when :neutral
      return self.new(player,map)
    end
  end
  
  def initialize(player, map)
    @player = player
    @map = map
  end
  
  def beginTurn
    @rolled = 0
    if @player.spawn_roll > 0
      if @player.spawn_roll == 1
        @rolled = 1
      else
        @rolled = rand(@player.spawn_roll) +1
      end
    end
    @player.number_to_spawn = @rolled
  end
  
  def click(loc)
    
  end
  
  def spawn_at(chosen)
    chosen.reinforce(@player, 1)
    @player.number_to_spawn -= 1
    Engine.instance.messages << "#{@player.name} spawned at #{chosen.name}"
  end
  
  def turn_complete?
    return @player.number_to_spawn <= 0
  end
  
  def update(delay)
    
  end
  
end

class AIController < TurnController
  
end

class HumanController < TurnController
  
  def click(loc)
    return if turn_complete?
    dists = @map.hotspots.collect do | spot |
      dx = loc[0] - spot.x
      dy = loc[1] - spot.y
      Math.sqrt(dx**2 + dy**2)
    end
    min_dist = dists.min
    
    chosen = @map.hotspots[dists.index(min_dist)]

    if chosen.can_spawn_here?(@player)
      spawn_at(chosen)
    else
      spawnmsg = "You can only spawn in places you control or "+
        "places next to them"
      Engine.instance.messages << spawnmsg
    end
  end
  
end