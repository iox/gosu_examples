require 'gosu'

class GameWindow < Gosu::Window
  def initialize(width=800, height=600, fullscreen=false)
    super
    self.caption = 'Hello Movement'
    @x = @y = 10
    @draws = 0
    @buttons_down = 0
    @background_image = Gosu::Image.new("background.jpg", :tileable => true)
    @character = Gosu::Image.new("character.png", retro: true, rect: [100,150,300,500])
    @music = Gosu::Song.new("alicia_sevilla_encuentro_con_el_noctambulo.mp3")
    @music.play

    @ball = Ball.new(self)
    @max_x = width - @ball.width
    @max_y = height - @ball.height
  end

  def update
    @x -= 2 if button_down?(Gosu::KbLeft)
    @x += 2 if button_down?(Gosu::KbRight)
    update_ball_location
  end

  def button_down(id)
    close if id == Gosu::KbEscape
    @buttons_down += 1
  end

  def button_up(id)
    @buttons_down -= 1
  end

  def needs_redraw?
    true# @draws < 10 || @buttons_down > 0
  end

  def draw
    @background_image.draw(0, 0, 0)
    @draws += 1
    # x, y, z, scale_x, scale_y
    @character.draw(@x, 530, 1, 0.15, 0.15)

    @ball.draw
  end


  def update_ball_location
    @ball.move

    if @ball.x < 0 || @ball.x > @max_x
      @ball.velocity_x = -@ball.velocity_x

      if @ball.x < 0
        @ball.x = 0
      elsif @ball.x > @max_x
        @ball.x = @max_x
      end
    end

    if @ball.y < 0 || @ball.y > @max_y 
      @ball.velocity_y = -@ball.velocity_y

      if @ball.y < 0
        @ball.y = 0
      elsif @ball.y > @max_y
        @ball.y = @max_y
      end
    end
end

end







module ZOrder
  Background, Ball, UI = (0..5).to_a
end

class Ball
  attr_accessor :x, :y, :velocity_x, :velocity_y

  def initialize(window)
    @x = rand(window.width)
    @y = rand(window.height)
    @velocity_x = 4.0
    @velocity_y = 4.0

    @image = Gosu::Image.new("ball.png") 
  end

  def draw
    @image.draw(@x, @y, ZOrder::Ball)
  end

  def location
    [@x, @y]
  end

  def width
    @image.width
  end

  def height
    @image.height
  end

  def move
    @x += @velocity_x
    @y += @velocity_y
  end
end







window = GameWindow.new
window.show





