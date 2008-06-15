require 'globals'

require 'optparse'
require 'ostruct'
def parse_args(args = ARGV)
  options = OpenStruct.new
  options.controllers = []
  options.map = 'pirates.yml'
  options.gui = true
  
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
    
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
    
  end
  
  opts.parse!(args)

  return options
end
