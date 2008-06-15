

$GEM_NAME = 'porttown'
$PORTTOWN_VERSION = [0,1,0]

$HOTSPOT_FONT = "LiberationSans-Regular.ttf"
$HOTSPOT_COLOR = [0, 0, 0, 0]

$DEFAULT_LABEL_FONT = "LiberationSans-Regular.ttf"
$DEFAULT_LABEL_COLOR = [255,255,255,0]

$MQV_COLOR = [0,0,255,0]

class Array
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