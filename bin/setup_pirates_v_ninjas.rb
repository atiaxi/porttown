#!/usr/bin/env ruby

require 'yaml'

$: << 'lib'
require 'model'

def main
  map = Map.new
  
  pirates = Player.new(0, 'Pirates')
  pirates.controller = :person
  zombies = Player.new(1, 'Zombies')
  zombies.controller = :person
  neutral = Player.new(2, 'Civilians')
  neutral.controller = :neutral
  
  map.add_player(pirates)
  map.add_player(zombies)
  map.add_player(neutral)
  
  ship = Hotspot.new("Pirate Ship")
  ship.base_of(pirates)
  ship.reinforce(pirates,6)
  ship.loc = [400,380]
  map.add_hotspot(ship)
  
  tavern = Hotspot.new("Tavern")
  tavern.connect_to(ship)
  tavern.reinforce(neutral, 3)
  tavern.loc = [600, 300]
  map.add_hotspot(tavern)
  
  slums = Hotspot.new("Slums")
  slums.connect_to(tavern)
  slums.connect_to(ship)
  slums.reinforce(neutral, 4)
  slums.loc = [500, 300]
  map.add_hotspot(slums)
  
  watch = Hotspot.new("Town Watch")
  watch.connect_to(slums)
  watch.reinforce(neutral, 4)
  watch.loc = [ 100, 295 ]
  map.add_hotspot(watch)
  
  church = Hotspot.new("Church")
  church.connect_to(watch)
  church.reinforce(neutral, 6)
  church.loc = [100, 200 ]
  map.add_hotspot(church)
  
  graveyard = Hotspot.new("Graveyard")
  graveyard.connect_to(church)
  graveyard.loc = [100, 50 ]
  map.add_hotspot(graveyard)
  
  mayor = Hotspot.new("Mayor's Villa")
  mayor.reinforce(neutral, 1)
  mayor.loc = [390, 75 ]
  map.add_hotspot(mayor)
  
  nobles = Hotspot.new("Nobles' Residences")
  nobles.connect_to(mayor)
  nobles.reinforce(neutral, 3)
  nobles.loc = [610, 75]
  map.add_hotspot(nobles)
  
  market = Hotspot.new("Marketplace")
  market.connect_to(nobles)
  market.reinforce(neutral, 10)
  market.loc = [700, 175 ]
  map.add_hotspot(market)
  
  main_street = Hotspot.new("Main Street")
  main_street.connect_to(slums)
  main_street.connect_to(church)
  main_street.connect_to(mayor)
  main_street.connect_to(market)
  main_street.reinforce(neutral, 6)
  main_street.loc = [400, 200]
  map.add_hotspot(main_street)
  
  puts YAML::dump(map)
  
end


if File.basename($0) == File.basename(__FILE__)
  main()
end