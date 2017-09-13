# http://chipmunk-rb.github.io/chipmunk/
# https://github.com/gosu/gosu/wiki/Ruby-Chipmunk-Integration
# https://github.com/chipmunk-rb/chipmunk

require 'gosu'
require 'chipmunk'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
INFINITY = 1.0/0


class GameWindow < Gosu::Window
  
  attr_accessor :space

  def initialize(width=SCREEN_WIDTH, height=SCREEN_HEIGHT, fullscreen=false)
    super
    self.caption = 'Hello Movement'
    @x = 10
    @buttons_down = 0
    @background_image = Gosu::Image.new("background.jpg", :tileable => true)
    @character = Gosu::Image.new("character.png", retro: true, rect: [100,150,300,500])
    @music = Gosu::Song.new("alicia_sevilla_encuentro_con_el_noctambulo.mp3")
    @music.play
    @harpoon_sound = Gosu::Song.new("arrow.wav")
    @balloon_sound = Gosu::Song.new("balloon.mp3")

    @space = CP::Space.new
    @space.damping = 1
    @space.gravity = CP::Vec2.new(0, 20) 

    @floor = Floor.new(self)
    @balls = []
    2.times do
      @balls << Ball.new(self)
    end
    @last_shot = -1000



    @space.add_collision_func(:harpoon, :floor) do |harpoon_shape, floor_shape|
      @remove_harpoon = true
    end


    @space.add_collision_func(:harpoon, :ball) do |harpoon_shape, ball_shape|
      @explode_shape = ball_shape
      @remove_harpoon = true
    end

    @space.add_collision_func(:ball, :ball, &nil)
  end






  def update
    @x -= 5 if button_down?(Gosu::KbLeft)
    @x += 5 if button_down?(Gosu::KbRight)


    # If the up button is pressed, another ball appears - you can only shot once a second
    if button_down?(Gosu::KbUp) && Gosu.milliseconds > (@last_shot + 600)
      @last_shot = Gosu.milliseconds

      # We need to create a harpoon that moves up
      @harpoon = Harpoon.new(self, CP::Vec2.new(@x,450))
      @harpoon_sound.play
    end


    if @explode_shape
      ball = @balls.find{|b| b.body == @explode_shape.body}
      @space.remove_body(@explode_shape.body)
      @space.remove_shape(@explode_shape)
      @balls.delete(ball)

      if ball.scale > 0.4
        @balls << Ball.new(self, ball.body.p, ball.scale / 2, :left)
        @balls << Ball.new(self, ball.body.p, ball.scale / 2, :right)
      end

      @balloon_sound.play

      @explode_shape = nil
    end



    if @remove_harpoon == true
      if @harpoon
        @space.remove_body(@harpoon.body)
        @space.remove_shape(@harpoon.shape)
        @harpoon = nil
      end
      @remove_harpoon = false
    end



    6.times do
      @space.step(1.0/50.0)
    end
  end

  def button_down(id)
    close if id == Gosu::KbEscape
    @buttons_down += 1
  end

  def button_up(id)
    @buttons_down -= 1
  end

  def needs_redraw?
    true
  end

  def draw
    @background_image.draw(0, 0, 0)
    # x, y, z, scale_x, scale_y
    @character.draw(@x, 530, 1, 0.15, 0.15)

    @floor.draw
    @balls.each do |b|
      b.draw
    end
    @harpoon.draw if @harpoon
  end


end









module ZOrder
  Background, Ball, UI = (0..5).to_a
end









# The floor in which the balls bounce off
class Floor
    
  def initialize(window)
    @window = window    
    @color = Gosu::Color::BLACK
    
    # CHIPMUNK BODY.
    @body = CP::Body.new(INFINITY, INFINITY)

    # THIS IS WHERE WE POSITION OUR FLOOR, STARTING FROM TOP LEFT
    @body.p = CP::Vec2.new(0, 0)

    # IT IS NOT MOVING, VELOCITY IS 0
    @body.v = CP::Vec2.new(0, 0)
    
    # 2 VECTORS. IT DEFINES A LINE WITH A LENGTH OF SCREEN_WIDTH
    @left_top =     CP::Vec2.new(0,0)
    @right_top =    CP::Vec2.new(SCREEN_WIDTH, 0)
    @left_bottom =  CP::Vec2.new(0, SCREEN_HEIGHT)
    @right_bottom = CP::Vec2.new(SCREEN_WIDTH, SCREEN_HEIGHT)

    @elasticity = 1.0
    @friction = 0.0



    # TOP CHIPMUNK SHAPE (used for collisions)
    @shape = CP::Shape::Segment.new(@body,
                                    @left_top,
                                    @right_top,
                                    1)
    @shape.e = @elasticity
    @shape.u = @friction
    @shape.collision_type = :floor

    @window.space.add_static_shape(@shape) # STATIC SO THAT THE GRAVITY OF THE SPACE DOESN'T AFFECT IT
    
    # BOTTOM CHIPMUNK SHAPE (used for collisions)
    @shape = CP::Shape::Segment.new(@body,
                                    @left_bottom,
                                    @right_bottom,
                                    1)
    @shape.e = @elasticity
    @shape.u = @friction
    @shape.collision_type = :floor

    @window.space.add_static_shape(@shape) # STATIC SO THAT THE GRAVITY OF THE SPACE DOESN'T AFFECT IT

    # LEFT CHIPMUNK SHAPE (used for collisions)
    @shape = CP::Shape::Segment.new(@body,
                                    @left_top,
                                    @left_bottom,
                                    1)
    @shape.e = @elasticity
    @shape.u = @friction
    @shape.collision_type = :floor
    @window.space.add_static_shape(@shape) # STATIC SO THAT THE GRAVITY OF THE SPACE DOESN'T AFFECT IT

    # RIGHT CHIPMUNK SHAPE (used for collisions)
    @shape = CP::Shape::Segment.new(@body,
                                    @right_top,
                                    @right_bottom,
                                    1)
    @shape.e = @elasticity
    @shape.u = @friction
    @shape.collision_type = :floor
    @window.space.add_static_shape(@shape) # STATIC SO THAT THE GRAVITY OF THE SPACE DOESN'T AFFECT IT
  end
  
  def draw
    # DRAW TOP LINE
    @window.draw_line(@left_top.x, @left_top.y, @color,
                      @right_top.x, @right_top.y, @color,
                      1)

    # DRAW BOTTOM LINE
    @window.draw_line(@left_bottom.x, @left_bottom.y, @color,
                      @right_bottom.x, @right_bottom.y, @color,
                      1)

    # DRAW LEFT LINE
    @window.draw_line(@left_top.x, @left_top.y, @color,
                      @left_bottom.x, @left_bottom.y, @color,
                      1)

    # DRAW RIGHT LINE
    @window.draw_line(@right_top.x, @right_top.y, @color,
                      @right_bottom.x, @right_bottom.y, @color,
                      1)

  end
  
end






class Ball
  
  attr_reader :shape, :body, :scale
  
  BOX_SIZE = 10
  
  def initialize(window, position=CP::Vec2.new(50,80), scale=1.0, direction=:right)
    @window = window
    @color = Gosu::Color::BLACK


    #  Add a moving circle object.
    @scale = scale
    @radius = scale * 28.0
    mass = 2.0

    #  This time we need to give a mass and moment of inertia when creating the circle.
    @body = CP::Body.new mass, CP::moment_for_circle(mass, 0.0, @radius, CP::ZERO_VEC_2)

    @body.p = position
    if direction == :right
      @body.v = CP::Vec2.new(30,0)
    else
      @body.v = CP::Vec2.new(-30,0)
    end

    @shape = CP::Shape::Circle.new(@body, @radius, CP::Vec2.new(0,0))
    
    @shape.e = 1
    @shape.u = 0
    @shape.collision_type = :ball
    
    # WE ADD THE THE BODY AND SHAPE TO THE SPACE WHICH THEY WILL LIVE IN
    @window.space.add_body(@body)
    @window.space.add_shape(@shape)


    @image = Gosu::Image.new("ball.png")

  end
  
  def update
  end
  
  def draw
    
    @image.draw(@body.p.x - @radius, @body.p.y - @radius, 30, @scale, @scale)

  end
end






class Harpoon
  
  attr_reader :shape, :body, :scale
  
  BOX_SIZE = 10
  
  def initialize(window, position=CP::Vec2.new(10,400))
    @window = window
    @body = CP::Body.new(10, 100)
    @body.p = position
    @body.v = CP::Vec2.new(0,-150)
    
    @shape_verts = [
                    CP::Vec2.new(-BOX_SIZE, BOX_SIZE),
                    CP::Vec2.new(BOX_SIZE, BOX_SIZE),
                    CP::Vec2.new(BOX_SIZE, -BOX_SIZE),
                    CP::Vec2.new(-BOX_SIZE, -BOX_SIZE),
                   ]

    @shape = CP::Shape::Poly.new(@body,
                                 @shape_verts,
                                 CP::Vec2.new(0,0))

    @shape.e = 1
    @shape.u = 0
    @shape.collision_type = :harpoon

    # WE ADD THE THE BODY AND SHAPE TO THE SPACE WHICH THEY WILL LIVE IN
    @window.space.add_body(@body)
    @window.space.add_shape(@shape)

    @image = Gosu::Image.new("harpoon.png")
  end
  
  def update
  end
  
  def draw
    @image.draw(@body.p.x, @body.p.y, 30)
  end
end






window = GameWindow.new
window.show