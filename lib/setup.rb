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

def setup_pirates
  
end

def start_porttown
  Rubygame.init
  Rubygame::TTF.setup()
  flags = Rubygame::DOUBLEBUF | Rubygame::HWSURFACE
  screen = Rubygame::Screen.new( [ 800, 600], 0, flags)
  screen.title = "Port Town"
  
  engine = Engine.new(screen)
  engine.current_phase = 3
  engine.run
end

