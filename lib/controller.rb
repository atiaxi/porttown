
class FightController
  
  def initialize(map)
    @map = map
  end
  
  def test_for_elimination
    @map.active_players.dup.each do |player|
      @map.eliminate_player(player) if @map.eliminate_player?(player)
    end
  end
  
  def fight
    log = Engine.instance.logger
    
    @map.hotspots.each do | spot |
      original_forces = spot.forces.dup
      log.info("Fighting begins in #{spot.name}")
      @map.active_players.each do | player |
        other_players = @map.other_players(player)
        times = 0
        while times < spot.forces_for(player)
          log.info(" #{times}: #{player.name}")
          times += 1
          result = roll(player.dice_to_roll)
          log.info(" Our rolls: #{result.inspect}")
          our_roll = result.max
          other_players.each do | other |
            next if spot.forces_for(other) <= 0
            log.info(" Versus: #{other.name}")
            their_roll = roll(other.dice_to_roll).max
            log.info(" Their best roll: #{their_roll}")
            if our_roll > their_roll
              spot.attrit(other, 1)
            elsif their_roll > our_roll
              spot.attrit(player, 1)
            end
          end
        end
      end
    end
    test_for_elimination
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
    log = Engine.instance.logger
    @rolled = roll(1, @player.spawn_roll)
    log.info("#{@player.name} rolled to spawn #{@rolled.inspect}")  
    @player.number_to_spawn = @rolled[0]
    log.debug("  Number to spawn is: #{@player.number_to_spawn}")
  end
  
  def click(loc)
    
  end
  
  def spawn_at(chosen)
    chosen.reinforce(@player, 1)
    @player.number_to_spawn -= 1
    Engine.instance.messages << "#{@player.name} spawned at #{chosen.name}"
  end
  
  def turn_complete?
    #Engine.instance.logger.debug("Spawns left: #{@player.number_to_spawn}")
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