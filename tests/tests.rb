#!/usr/bin/env ruby

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