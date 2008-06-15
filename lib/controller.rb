# This file is part of Port Town.
#
# Port Town is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

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
              if player.lethal_conversion
                spot.reinforce(player, 1)
              end
            elsif winner == other
              spot.attrit(player, 1)
              if other.lethal_conversion
                spot.reinforce(other, 1)
              end
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
    # Only do bonuses if we could already spawn here
    # (i.e. we're not at spawn_limit)
    return false unless spot.can_spawn_here?(player)

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
    if @player.controller == :neutral
      Engine.instance.messages << "#{@player.name} was eliminated, skipping"
      @player.number_to_spawn = 0
      return
    end
    unless @map.can_spawn_anywhere?(@player)
      Engine.instance.messages << "#{@player.name} has nowhere to spawn, and "+
        "loses a turn"
      @player.number_to_spawn = 0      
      return
    end
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
  
  def initialize(player, map, speed = nil)
    super(player,map)
    @speed = speed || $ai_speed
    @counted = 0.0
  end
  
  # If we get a click, that's the person sitting at the
  # computer telling us to hurry up!
  def click(loc)
    @counted = @speed + 0.001  
  end
  
  def update(delay)
    @counted += delay
    if @counted > @speed
      @counted -= @speed
      spawn
    end
  end
  
end

class HumanController < TurnController
  
  def click(loc)
    return if turn_complete?
  end
  
end

class RandomAIController < AIController
  
  def spawn
    valid = @map.hotspots.select do | spot |
      spot.can_spawn_here?(@player)
    end
    spawn_at(valid.random) if valid.size > 0
  end
  
end