require 'gosu'

class GameWindow < Gosu::Window
  def initialize(width=800, height=600, fullscreen=false)
    super
    @x = @y = 10
  end

  def update
    @x -= 1 if button_down?(Gosu::KbLeft)
    @x += 1 if button_down?(Gosu::KbRight)
    @y -= 1 if button_down?(Gosu::KbUp)
    @y += 1 if button_down?(Gosu::KbDown)
  end

  def draw
    @message = Gosu::Image.from_text("x:#{@x}   y:#{@y}", 30)
    @message.draw(@x, @y, 0)
  end

end

window = GameWindow.new
window.show
