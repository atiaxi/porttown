require 'engine'

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