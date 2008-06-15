
class FightController
  
  def initialize(map, queue=nil)
    @map = map
    @queue = queue
  end
  
  def compile_report_for(spot, original_forces)
    original_forces.each_index do |i|
      player = @map.player_on_side(i)
      original = original_forces[player.side] || 0
      diff = original - spot.forces_for(player)
      if diff > 0
        report("#{player.name} lost #{diff} at #{spot.name}")
      end
    end
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
      @map.active_players.each do | player |
        other_players = @map.other_players(player)
        times = 0
        # Fight everyone else here
        while times < spot.forces_for(player)
          times += 1
          
          other_players.each do | other |
            next unless spot.forces_for(other) > 0
            winner = player.fight(other)
            if winner == player
              spot.attrit(other, 1)
#              if player.lethal_conversion
#                spot.reinforce(player, 1)
#              end
            elsif winner == other
              spot.attrit(player, 1)
#              if other.lethal_conversion
#                spot.reinforce(other, 1)
#              end
            end
          end
        end
        # See if we respawn anything
        spawn_bonuses(spot, player)
      end
      compile_report_for(spot, original_forces)
    end
    test_for_elimination
  end
  
  def report(string)
    @queue << string if @queue
    Engine.instance.logger.info(string) if $verbose
  end
  
  def spawn_bonuses(spot, player)
    # Do we loot people to pay for more of us?
    bodies = player.loot_threshold
    if bodies
      total = 0
      @map.neutral_players.each do  | neutral |
        next unless spot.forces_for(player) > 0
        total += (spot.forces_for(neutral) / bodies).to_i
      end
      
      if total > 0
        spot.reinforce(player, total)
        report("#{player.name} looted enough at #{spot.name} to pay for "+
          "#{total} more #{player.description}!")
      end
    end
    
    # Do we convert people into the living dead?
    if player.lethal_conversion
      
      @map.neutral_players.each do | neutral |
        next unless spot.forces_for(player) > 0
        next unless spot.forces_for(neutral) > 0
        
        victor = player.fight(neutral)
        if victor == player
          spot.attrit(neutral, 1)
          spot.reinforce(player, 1)
          report("#{player.name} converted a #{neutral.description} "+
            " into a #{player.description} at #{spot.name}!")
        elsif victor == neutral
          spot.attrit(player, 1)
          report("The #{neutral.name} in #{spot.name} drove off the "+
            "#{player.description}!")
        end
      end
      
    end
    
  end
  
end

class TurnController
  
  attr_reader :rolled
  
  def self.instance_for(player,map)
    case(player.controller)
    when :person
      return HumanController.new(player,map)
    when :cpu
      return RandomAIController.new(player,map)
    when :neutral
      return self.new(player,map)
    end
  end
  
  def initialize(player, map)
    @player = player
    @map = map
  end
  
  def beginTurn
    #log = Engine.instance.logger
    @rolled = roll(1, @player.spawn_roll)
    #log.info("#{@player.name} rolled to spawn #{@rolled.inspect}")  
    @player.number_to_spawn = @rolled[0]
    #log.debug("  Number to spawn is: #{@player.number_to_spawn}")
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

class RandomAIController < AIController
  
  def initialize(player, map, speed = nil)
    super(player,map)
    @speed = speed || $ai_speed
    @counted = 0.0
  end
  
  def spawn
    valid = @map.hotspots.select do | spot |
      spot.can_spawn_here?(@player)
    end
    spawn_at(valid.random)
  end
  
  def update(delay)
    @counted += delay
    if @counted > @speed
      @counted -= @speed
      spawn
    end
  end
  
end