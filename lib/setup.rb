#!/usr/bin/env ruby

require 'engine'
require 'placement'
require 'fight'
require 'globals'

require 'options'

def start_porttown
  Rubygame.init
  Rubygame::TTF.setup()
  
  options = parse_args
  map_name = options.map
  overrides = options.controllers
  
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
  exit unless map
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

