#!/usr/bin/env ruby

$: << "lib"

require 'options'
require 'engine'
require 'controller'

def run_headless
  
  options = parse_args
  map_name = options.map
  # Ignore overrides, we want all active players to be CPU
  map = Engine.instance.yaml_for(map_name)
  exit unless map
  
  placements = map.active_players.collect do |p|
    p.controller = :cpu
    TurnController.instance_for(p, map)
  end
  
  fc = FightController.new(map)
  
  until map.winner
    placements.each do |controller|
      controller.beginTurn
      controller.update(10000) until controller.turn_complete?
    end
    
    fc.fight
  end
  puts "#{map.winner.name} win!"
end

if File.basename($0) == File.basename(__FILE__)
  run_headless
end