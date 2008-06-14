#!/usr/bin/env ruby

begin
  require 'rubygems'
  gem 'rubygame', '>=2.3.0'
rescue LoadError
  # Either no gems or no rubygame
end

begin
  require 'rubygame'
rescue LoadError
  puts "This game requires Rubygame 2.3.0 or better"
  exit
end

require 'engine'
require 'placement'
require 'fight'

def start_porttown
  Rubygame.init
  Rubygame::TTF.setup()
  
  engine = Engine.instance
  engine.screen.title = "Port Town"
  # TODO: Command line parsing and such.  For now, we do whatever the default
  # map says
  map = engine.yaml_for("pirates.yml")
  
  placement_phases = map.active_players.collect do | p |
    PlacementPhase.new(map, p)
  end
  
  engine.add_phases(placement_phases)
  engine.add_phase(FightPhase.new(map))
  engine.run
end

