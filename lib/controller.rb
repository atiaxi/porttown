
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
        while times < spot.forces_for(player)
          times += 1
          result = roll(player.dice_to_roll)
          our_roll = result.max
          other_players.each do | other |
            next if spot.forces_for(other) <= 0
            their_roll = roll(other.dice_to_roll).max
            if our_roll > their_roll
              spot.attrit(other, 1)
            elsif their_roll > our_roll
              spot.attrit(player, 1)
            end
          end
        end
      end
      compile_report_for(spot, original_forces)
    end
    test_for_elimination
  end
  
  def report(string)
    @queue << string if @queue
    #Engine.instance.logger.info(string)
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
  
  def initialize(player, map, speed = 1.0)
    super(player,map)
    @speed = speed
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