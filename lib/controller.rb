
class TurnController
  
  attr_reader :rolled
  
  def initialize(player)
    @player = player
  end
  
  def beginTurn
    if @player.spawn_roll > 0
      if @player.spawn_roll = 1
        @rolled = 1
      else
        @rolled = rand(@player.spawn_roll)
      end
    end
    @player.number_to_spawn = @rolled
  end
  
end