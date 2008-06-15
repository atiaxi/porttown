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

