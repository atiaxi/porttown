require 'globals'

class HotspotView
  
  def initialize(hotspot, offset)
    @font = Engine.instance.font_for($HOTSPOT_FONT)
    @offset = offset
    x = @offset[0] + hotspot.x
    y = @offset[1] + hotspot.y
    @rect = Rubygame::Rect.new(x,y, 1, 1)
    @image = nil
    @spot = hotspot
  end
  
  def draw(screen)
    # Draw lines between us and our connections
    @spot.connected_to.each do | other |
      otherx = other.x + @offset[0]
      othery = other.y + @offset[1]
      screen.draw_line(@rect.center, [otherx,othery], $HOTSPOT_LINE_COLOR)
    end
    
    
    blit_at = image.make_rect
    blit_at.center = @rect.center
    image.blit(screen, blit_at.topleft)
  end
  
  def image
    return @image if @image
    @image = @font.render(@spot.name, true, $HOTSPOT_COLOR)
    return @image
  end
  
end

class MapView
  
  def initialize(map,aspect = Rubygame::Rect.new(0, 100, 800, 400))
    @map = map
    @rect = aspect
    @spots = map.hotspots.collect do | spot |
      HotspotView.new(spot, @rect.topleft)
    end
  end
  
  def draw(screen)
    screen.fill(Rubygame::Color[:green], @rect)
    @spots.each do | spot |
      spot.draw(screen)
    end
    
  end
  
end

class PlacementPhase < Phase
  
  def initialize(map, forPlayer)
    super()
    @player = forPlayer
    @mapView = MapView.new(map)
  end
  
  def draw(screen)
    @mapView.draw(screen)
  end
  
end