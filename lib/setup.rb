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
require 'globals'

require 'optparse'

def parse_args(args = ARGV)
  controllers = []
  map = 'pirates.yml'
  
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: porttown [options]"    
    
    opts.on("-m", "--map MAPNAME",
      "Name of the map to load, without extension") do |mapname|
        
      map = mapname+".yml"
    end
    
    opts.on("-c x,y,z", "--cpu x,y,z", Array, 
      "Force the given players to be CPU players") do | list |
      list.each { |index| controllers[index.to_i-1] = :cpu }
    end
    
    opts.on("-H x,y,z", "--human x,y,z", Array,
      "Force the given players to be human players") do |list|
      list.each { |index| controllers[index.to_i-1] = :person }        
    end
    
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
    
  end
  
  opts.parse!(args)

  return map, controllers
end

def start_porttown
  Rubygame.init
  Rubygame::TTF.setup()
  
  map_name, overrides = parse_args
  engine = Engine.instance
  engine.screen.title = "Port Town"
  
  if engine.is_gem?($GEM_NAME)
    gem_root = Gem.loaded_specs[$GEM_NAME].full_gem_path
    engine.add_autoload(File.join(gem_root, "data"))
    engine.add_autoload(File.join(gem_root, "images"))
  end
  
  # TODO: Command line parsing and such.  For now, we do whatever the default
  # map says
  map = engine.yaml_for(map_name)
  overrides.each_index do | index |
    next unless overrides[index]
    player = map.player_on_side(index)
    player.controller = overrides[index]
  end
  
  placement_phases = map.active_players.collect do | p |
    PlacementPhase.new(map, p)
  end
  
  engine.add_phases(placement_phases)
  engine.add_phase(FightPhase.new(map))
  engine.run
end

