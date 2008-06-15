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
  
  def controller
    return @fc
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