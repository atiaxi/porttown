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

require 'globals'

require 'optparse'
require 'ostruct'
def parse_args(args = ARGV)
  options = OpenStruct.new
  options.controllers = []
  options.map = 'pirates.yml'
  options.gui = true
  options.repeat = 1
  
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: porttown [options]"    
    
    opts.on("-m", "--map MAPNAME",
      "Name of the map to load, without extension") do |mapname|
        
      options.map = mapname+".yml"
    end
    
    opts.on("-c x,y,z", "--cpu x,y,z", Array, 
      "Force the given players to be CPU players") do | list |
      list.each { |index| options.controllers[index.to_i-1] = :cpu }
    end
    
    opts.on("-H x,y,z", "--human x,y,z", Array,
      "Force the given players to be human players") do |list|
      list.each { |index| options.controllers[index.to_i-1] = :person }        
    end
    
    opts.on("-t", "--text-speed [msec]", Integer,
      "Speed of text, in milliseconds") do |ms|
      $text_speed = ms / 1000.0    
    end
    
    opts.on("-a", "--ai-speed [msec]", Integer,
      "Speed of the AI, in milliseconds") do |ms|
        $ai_speed = ms /1000.0
    end
    
    opts.on("-v", "--verbose", "Log notices") do |verb|
      $verbose = verb
    end
    
    opts.on("-r", "--repeat [times]", Integer, "Re-run the scenario",
      "(Headless mode only)") do |times|
      options.repeat = times
    end
    
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
    
    opts.on_tail("--version", "Show version") do
      puts "porttown v#{$PORTTOWN_VERSION.join(".")}"
      exit
    end
    
  end
  
  opts.parse!(args)

  return options
end
