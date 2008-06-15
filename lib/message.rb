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
