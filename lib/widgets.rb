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
  
  attr_reader :color
  
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
