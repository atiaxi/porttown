require 'globals'

class FightPhase < Phase
  
  def initialize(map)
    super()
    @map = map
    @queue = MessageQueue.new
    @fc = FightController.new(map,@queue)
    @mqv = MessageQueueView.new([100, 10], 600, @queue)
    @widgets << @mqv
  end
  
  def activate
    @queue.clear
    @queue << "Fight report:"
    @fc.fight
    
    if @map.winner
      @queue << "#{@map.winner.name} win!"
    else
      @queue << "Click to continue"
    end
  end
  
  def click(loc)
    exit if @map.winner
    Engine.instance.done
  end
  
  def draw(screen)
    super
  end
  
  def update(delay)
    @mqv.update(delay)
  end
end