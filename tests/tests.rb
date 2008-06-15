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

# Yes, I'm writing unit tests in a 48 hour game competition, because clearly I
# have gone bonkers.

require 'test/unit'

$: << '../lib'
$: << '../bin'

# These next three are for eclipse, as it refuses to run in this directory
$: << './tests'
$: << './lib'
$: << './bin'

require 'controller'

class TC_Gameover < Test::Unit::TestCase
  
  def setup
    require 'setup_pirates_v_zombies'
    
    @map = piratesVzombies
    @pirates = @map.players[0]
    @zombies = @map.players[1]
    
    @fight = FightController.new(@map)
  end
  
  def test_nobody_winning
    assert_nil(@map.winner)
  end
  
  def test_pirates_winning
    graveyard = @map.hotspot_by_name("Graveyard")
    graveyard.eliminate(@zombies)
    graveyard.reinforce(@pirates, 1)
    @fight.test_for_elimination
    assert_not_nil(@map.winner)
    assert_equal(@pirates, @map.winner)
  end
  
  def test_zombies_winning
    ship = @map.hotspot_by_name("Pirate Ship")
    ship.eliminate(@pirates)
    ship.reinforce(@zombies, 1)
    @fight.test_for_elimination
    assert_not_nil(@map.winner)
    assert_equal(@zombies, @map.winner)
    
  end
  
end