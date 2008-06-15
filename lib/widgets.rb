require 'globals'
require 'message'

class Widget
  attr_accessor :rect
  
  def initialize
    @rect = Rubygame::Rect.new
    @image = nil
  end
  
  def draw(screen)
    if @image && @rect
      @image.blit(screen, @rect.topleft)
    end
  end
  
end

class Label < Widget
  
  def initialize(text, font=$DEFAULT_LABEL_FONT, size=16, color=$DEFAULT_LABEL_COLOR)
    super()
    @font = Engine.instance.font_for(font,size)
    @color = color
    self.text = text
  end
  
  def color=(color)
    @color = color
    self.text = @text_string
  end
  
  def text=(text)
    @text_string = text
    @image = @font.render(text, true, @color)
    @rect.w = @image.w
    @rect.h = @image.h
  end
  
end

class MessageQueueView < Widget
  
  def initialize(offset, width, queue)
    super()
    @offset = offset
    @rect.x = offset[0]
    @rect.y = offset[1]
    @rect.w = width
    @labels = []
    @queue = queue
    setup_labels
  end
  
  def draw(screen)
    screen.fill($MQV_COLOR ,@rect)
    @labels.each { |l| l.draw(screen) }
  end
  
  def setup_labels
    @labels = []
    h = 0
    @queue.each do | message |
      label = Label.new(message.to_s)
      label.rect.x = @rect.x
      label.rect.y = @rect.y + (@labels.size * label.rect.h)
      @labels << label
      h += label.rect.h
    end
    @rect.h = h
  end
  
  def update(delay)
    setup_labels
  end
  
end
