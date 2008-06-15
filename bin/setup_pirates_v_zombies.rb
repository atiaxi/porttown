#!/usr/bin/env ruby

require 'yaml'

$: << 'lib'
require 'model'

def piratesVzombies 
  map = Map.new
  map.background = "port_town.png"
  
  pirates = Player.new(0, 'Pirates')
  pirates.controller = :person
  pirates.spawn_roll = 3
  pirates.dice_to_roll = 2
  pirates.loot_threshold = 4
  pirates.spawn_limit = 10
  pirates.crit_dice = 2
  pirates.crit_number = 1
  pirates.description = "buccaneer"
  zombies = Player.new(1, 'Zombies')
  zombies.controller = :cpu
  zombies.spawn_roll = 6
  zombies.dice_to_roll = 1
  zombies.lethal_conversion = true
  zombies.spawn_limit = 15
  zombies.weakness = nil
  zombies.description = "living dead"
  neutral = Player.new(2, 'Civilians')
  neutral.controller = :neutral
  neutral.dice_to_roll = 1
  
  map.add_player(pirates)
  map.add_player(zombies)
  map.add_player(neutral)
  
  ship = Hotspot.new("Pirate Ship")
  ship.base_of(pirates)
  ship.reinforce(pirates,6)
  ship.loc = [475,380]
  map.add_hotspot(ship)
  
  tavern = Hotspot.new("Tavern")
  tavern.connect_to(ship)
  tavern.reinforce(neutral, 3)
  tavern.loc = [725, 380]
  map.add_hotspot(tavern)
  
  slums = Hotspot.new("Slums")
  slums.connect_to(tavern)
  slums.connect_to(ship)
  slums.reinforce(neutral, 4)
  slums.loc = [575, 275]
  map.add_hotspot(slums)
  
  watch = Hotspot.new("Town Watch")
  watch.connect_to(slums)
  watch.reinforce(neutral, 4)
  watch.loc = [ 175, 310 ]
  map.add_hotspot(watch)
  
  church = Hotspot.new("Church")
  church.connect_to(watch)
  church.reinforce(neutral, 6)
  church.loc = [175, 180 ]
  map.add_hotspot(church)
  
  graveyard = Hotspot.new("Graveyard")
  graveyard.connect_to(church)
  graveyard.loc = [175, 70 ]
  graveyard.base_of(zombies)
  graveyard.reinforce(zombies, 6)
  map.add_hotspot(graveyard)
  
  mayor = Hotspot.new("Mayor's Villa")
  mayor.reinforce(neutral, 1)
  mayor.loc = [475, 75 ]
  map.add_hotspot(mayor)
  
  nobles = Hotspot.new("Nobles' Residences")
  nobles.connect_to(mayor)
  nobles.reinforce(neutral, 3)
  nobles.loc = [710, 75]
  map.add_hotspot(nobles)
  
  market = Hotspot.new("Marketplace")
  market.connect_to(nobles)
  market.reinforce(neutral, 10)
  market.loc = [610, 175 ]
  map.add_hotspot(market)
  
  main_street = Hotspot.new("Fountain")
  main_street.connect_to(slums)
  main_street.connect_to(church)
  main_street.connect_to(mayor)
  main_street.connect_to(market)
  main_street.reinforce(neutral, 6)
  main_street.loc = [475, 180]
  map.add_hotspot(main_street)
  
  return map
end

def main
  
  puts YAML::dump(piratesVzombies)
  
end


if File.basename($0) == File.basename(__FILE__)
  main()
end