require 'globals'
require 'widgets'
require 'controller'

class MessageQueueView < Widget
  
  def initialize(offset, width)
    super()
    @offset = offset
    @rect.x = offset[0]
    @rect.y = offset[1]
    @rect.w = width
    @labels = []
    setup_labels
  end
  
  def draw(screen)
    screen.fill($MQV_COLOR ,@rect)
    @labels.each { |l| l.draw(screen) }
  end
  
  def setup_labels
    @labels = []
    h = 0
    messages = Engine.instance.messages
    messages.each do | message |
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

class HotspotView < Widget
  
  def initialize(hotspot, offset, players)
    super()
    @font = Engine.instance.font_for($HOTSPOT_FONT)
    @offset = offset
    @spot = hotspot
    @players = players
    setup_hotspot_labels
  end
  
  def draw(screen)
    @spot.connected_to.each do | other |
      otherx = other.x + @offset[0]
      othery = other.y + @offset[1]
      screen.draw_line(@rect.midbottom, [otherx,othery], $HOTSPOT_LINE_COLOR)
    end
    
    @name_label.draw(screen)
    @player_labels.each { |l| l.draw(screen) }
    
  end
  
  def image
    return @image if @image
    @image = @font.render(@spot.name, true, $HOTSPOT_COLOR)
    @rect.w = @image.w
    @rect.h = @image.h
    @rect.centerx = @offset[0] + @spot.x
    @rect.centery = @offset[1] + @spot.y
    return @image
  end
  
  def setup_hotspot_labels
    @name_label = Label.new(@spot.name, $HOTSPOT_FONT, 16, $HOTSPOT_COLOR)
    @rect.w = @name_label.rect.w
    @rect.centerx = @offset[0] + @spot.x
    
    @players_to_labels = {}
    h = @name_label.rect.h
    @player_labels = @players.collect do |player|
      l = Label.new("foo", $HOTSPOT_FONT, 12, $HOTSPOT_COLOR)
      h += l.rect.h
      @players_to_labels[player] = l
      l
    end
    @rect.h = h
    @rect.bottom = @offset[1] + @spot.y
    
    @name_label.rect.bottom = @rect.bottom
    @name_label.rect.centerx = @rect.centerx
    @players.each_index do | index |
      player = @players[index]
      label = @players_to_labels[player]
      h = label.rect.h
      label.rect.bottom = @name_label.rect.top - (index * h)
    end
    update_hotspot_labels
  end
  
  def update(delay)
    update_hotspot_labels
  end
  
  def update_hotspot_labels
    @players.each do | player |
      label = @players_to_labels[player]
      label.text = "#{player.name}: #{@spot.forces_for(player)}"
      label.rect.centerx = @rect.centerx
    end
  end
  
end

class MapView < Widget
  
  def initialize(map,aspect = Rubygame::Rect.new(0, 100, 800, 400))
    super()
    @map = map
    @rect = aspect
    @spots = map.hotspots.collect do | spot |
      HotspotView.new(spot, @rect.topleft, @map.players)
    end
  end
  
  def draw(screen)
    screen.fill(Rubygame::Color[:green], @rect)
    @spots.each do | spot |
      spot.draw(screen)
    end
    
  end
  
  def update(delay)
    @spots.each { |s| s.update(delay) }
  end
  
end

class PlacementPhase < Phase
  
  def initialize(map, forPlayer)
    super()
    @player = forPlayer
    @mapView = MapView.new(map)
    @controller = TurnController.instance_for(@player, map)
    @turnLabel = Label.new("#{@player.name} turn")
    @turnLabel.rect.center = [ @engine.screen.w / 2, 550]
    @widgets << @turnLabel
    
    @spawnLabel = Label.new("Placement phase: X more to place")
    @spawnLabel.rect.top = @turnLabel.rect.bottom + 3
    @spawnLabel.rect.centerx = @turnLabel.rect.centerx
    @widgets << @spawnLabel

    @mqv = MessageQueueView.new([1,1], @engine.screen.w - 2)
    @widgets << @mqv
  end
  
  def activate
    @mqv.setup_labels
    @engine.messages << "#{@player.name} turn begins"
    @spawnLabel.text = "Calculating..."
    @controller.beginTurn
    update_spawnLabel
  end
  
  def click(loc)
    @controller.click([loc[0]-@mapView.rect.x, loc[1]-@mapView.rect.y])
    update_spawnLabel
  end
  
  def draw(screen)
    @mapView.draw(screen)
    super
  end
  
  def update(delay)
    @mapView.update(delay)
    @mqv.update(delay)
    @controller.update(delay)
    update_spawnLabel
    @engine.done if @controller.turn_complete?
  end
  
  def update_spawnLabel
    @spawnLabel.text = "Placement phase: #{@player.number_to_spawn} "+
      "more to place"
    @spawnLabel.rect.centerx = @turnLabel.rect.centerx    
  end
  
end