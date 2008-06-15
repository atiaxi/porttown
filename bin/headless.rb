#!/usr/bin/env ruby

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

$: << "lib"

require 'options'
require 'engine'
require 'controller'

def run_headless
  
  options = parse_args
  map_name = options.map
  
  turns = 0
  
  options.repeat.times do 
    rounds = 0
    # Ignore overrides, we want all active players to be CPU
    map = Engine.instance.yaml_for(map_name)
    exit unless map
    
    placements = map.active_players.collect do |p|
      p.controller = :cpu
      TurnController.instance_for(p, map)
    end
    
    fc = FightController.new(map)
    
    until map.winner
      rounds += 1
      placements.each do |controller|
        controller.beginTurn
        controller.update(10000) until controller.turn_complete?
      end
      
      fc.fight
    end
    puts "#{map.winner.name} win in #{rounds} turns"
    turns += rounds
  end
  puts "-----"
  puts "#{turns} total turns, avg. turns/round = #{turns.to_f/options.repeat}"
end

if File.basename($0) == File.basename(__FILE__)
  run_headless
end