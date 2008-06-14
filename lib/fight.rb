require 'globals'

class FightPhase < Phase
  
  def initialize(map)
    super()
    @map = map
    @fc = FightController.new(map)
  end
  
  def activate
    @fc.fight
    
    if @map.winner
      Engine.instance.logger.info("#{@map.winner.name} win!")
      exit
    end
    Engine.instance.done
  end
  
end