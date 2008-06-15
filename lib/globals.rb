

$GEM_NAME = 'porttown'
$PORTTOWN_VERSION = [0,2,0]

$HOTSPOT_FONT = "LiberationSans-Regular.ttf"
$HOTSPOT_COLOR = [0, 0, 0, 0]
$HOTSPOT_HIGHLIGHT = [255, 255, 255, 0]

$DEFAULT_LABEL_FONT = "LiberationSans-Regular.ttf"
$DEFAULT_LABEL_COLOR = [255,255,255,0]

$MQV_COLOR = [0,0,255,0]

# Set by command line options
$text_speed = 3.0
$ai_speed = 2.5
$verbose = false

class Array
  # I could have sworn this already existed
  def count(item)
    return (self.select { |x| x == item }).size
  end
  
  def random
    if size > 0
      return self[rand(size)]
    else
      return nil
    end
  end

end

# Rolls the given number of d(sides) dice.
# Returns an array of the rolls
def roll(number=1, sides=6)
  return nil if number <= 0
  return nil if sides <= 0
  result = []
  number.times do
    if sides == 1
      result << 1
    else
      result << rand(sides)+1
    end
  end
  return result
end