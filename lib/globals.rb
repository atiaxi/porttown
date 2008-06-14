
$HOTSPOT_FONT = "LiberationSans-Regular.ttf"
$HOTSPOT_COLOR = Rubygame::Color[:black]
$HOTSPOT_LINE_COLOR = Rubygame::Color[:gray]

$DEFAULT_LABEL_FONT = "LiberationSans-Regular.ttf"
$DEFAULT_LABEL_COLOR = Rubygame::Color[:white]

$MQV_COLOR = Rubygame::Color[:blue]

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