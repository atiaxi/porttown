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

class Message
  
  include Comparable
  
  attr_accessor :time
  attr_accessor :msg
  
  def initialize(message, display_for=nil)
    @msg = message
    @time = display_for || $text_speed
  end
  
  def <=>(other)
    return self.time <=> other.time
  end
  
  def as_message
    return self
  end
  
  def to_s
    return msg
  end
  
end

class String
  def as_message
    return Message.new(self)
  end
end

class MessageQueue
  
  def initialize
    @queue = []
  end
  
  def <<(msg)
    add_message(msg)
  end
  
  def add_message(msg)
    @queue << msg.as_message
  end
  
  def clear
    @queue.clear
  end
  
  def each(&proc)
    return @queue.each(&proc)
  end
  
  def update(delay)
    @queue.dup.each do | m |
      m.time -= delay
      @queue.delete(m) if m.time <= 0
    end
  end
  
end
