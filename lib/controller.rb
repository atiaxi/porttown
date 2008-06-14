
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
    Engine.instance.logger.debug("Map is #{map}")
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
    Engine.instance.logger.debug("Rolled: #{@rolled}")
    @player.number_to_spawn = @rolled
  end
  
  def click(loc)
    
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

    spawn_at(chosen)

  end

  def spawn_at(chosen)
    chosen.reinforce(@player, 1)
    @player.number_to_spawn -= 1
  end
  
end