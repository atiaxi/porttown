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
require 'widgets'
require 'controller'


class HotspotView < Widget
  
  def initialize(hotspot, offset, players)
    super()
    @font = Engine.instance.font_for($HOTSPOT_FONT)
    @offset = offset
    @spot = hotspot
    @players = players
    @color = $HOTSPOT_COLOR
    setup_hotspot_labels
  end
  
  def color=(new_color)
    return if new_color == @color
    @color = new_color
    setup_hotspot_labels
  end
  
  def draw(screen)
#    @spot.connected_to.each do | other |
#      otherx = other.x + @offset[0]
#      othery = other.y + @offset[1]
#      screen.draw_line(@rect.midbottom, [otherx,othery], $HOTSPOT_LINE_COLOR)
#    end
    
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
  
  def model
    return @spot
  end
  
  def setup_hotspot_labels
    @name_label = Label.new(@spot.name, $HOTSPOT_FONT, 16, @color)
    @rect.w = @name_label.rect.w
    @rect.centerx = @offset[0] + @spot.x
    
    @players_to_labels = {}
    h = @name_label.rect.h
    @player_labels = @players.collect do |player|
      l = Label.new("foo", $HOTSPOT_FONT, 12, @color)
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
  
  attr_reader :spots
  
  def initialize(map,aspect = Rubygame::Rect.new(0, 100, 800, 400))
    super()
    @map = map
    @rect = aspect
    @spots = map.hotspots.collect do | spot |
      HotspotView.new(spot, @rect.topleft, @map.players)
    end
    if map.background
      @background = Engine.instance.image_for(map.background)
    else
      @background = nil
    end
  end
  
  def draw(screen)
    screen.fill(Rubygame::Color[:green], @rect)
    if @background
      @background.blit(screen, @rect.topleft)
    end
    @spots.each do | spot |
      spot.draw(screen)
    end
    
  end
  
  def update(delay)
    @spots.each { |s| s.update(delay) }
  end
  
end

class PlacementPhase < Phase
  
  attr_reader :controller
  
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

    @mqv = MessageQueueView.new([1,1], @engine.screen.w - 2, @engine.messages)
    @widgets << @mqv
  end
  
  def activate
    @engine.messages << "#{@player.name} turn begins"
    @controller.beginTurn
    update_graphics
  end
  
  def click(loc)
    @controller.click(loc)
    return unless @player.controller == :person
    
    if @player.can_spawn?
      clicked = nearest_hotspot_to(loc)
      model = clicked.model
      if model.can_spawn_here?(@player)
        @controller.spawn_at(model)
      else
        spawnmsg = ''
        if (@player.spawn_limit &&
            model.forces_for(@player) >= @player.spawn_limit)
          spawnmsg = "#{model.name} cannot hold more than " +
            "#{@player.spawn_limit} #{@player.name}"
        else
          spawnmsg = "You can only spawn in places you control or "+
            "places next to them"
        end
        Engine.instance.messages << spawnmsg
      end
    end
    
    update_graphics
  end
  
  def draw(screen)
    @mapView.draw(screen)
    super
  end
  
  def hover(loc)
    return unless @player.controller == :person
    hot = nearest_hotspot_to(loc)
    @mapView.spots.each do | spot |
      if spot == hot
        spot.color = $HOTSPOT_HIGHLIGHT
      else
        spot.color = $HOTSPOT_COLOR
      end
    end
  end
  
  def nearest_hotspot_to(loc)
    dists = @mapView.spots.collect do | spot |
      dx = loc[0] - spot.rect.centerx
      dy = loc[1] - spot.rect.centery
      Math.sqrt(dx**2 + dy**2)
    end
    min_dist = dists.min
    chosen = @mapView.spots[dists.index(min_dist)]
    
    return chosen
  end
  
  def update(delay)
    @controller.update(delay)
    update_graphics(delay)
    @engine.done if @controller.turn_complete?
  end
  
  def update_graphics(delay= 0.001)
    @mapView.update(delay)
    @mqv.update(delay)
    update_spawnLabel
  end
  
  def update_spawnLabel
    @spawnLabel.text = "Placement phase: #{@player.number_to_spawn} "+
      "more to place"
    @spawnLabel.rect.centerx = @turnLabel.rect.centerx    
  end
  
end