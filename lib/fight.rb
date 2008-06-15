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
    @waited = 0.0
    @queue << "Fight report:"
    @fc.fight
    
    if @map.winner
      @queue << "#{@map.winner.name} win!"
      puts "#{@map.winner.name} win!" if @map.automated
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
    if @map.automated
      @waited += delay
      Engine.instance.done if @waited > $ai_speed * 2
    end
  end
end