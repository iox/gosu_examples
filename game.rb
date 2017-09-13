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
  end

  def update
    @x -= 2 if button_down?(Gosu::KbLeft)
    @x += 2 if button_down?(Gosu::KbRight)
    @y -= 2 if button_down?(Gosu::KbUp)
    @y += 2 if button_down?(Gosu::KbDown)
  end

  def button_down(id)
    close if id == Gosu::KbEscape
    @buttons_down += 1
  end

  def button_up(id)
    @buttons_down -= 1
  end

  def needs_redraw?
    @draws < 10 || @buttons_down > 0
  end

  def draw
    @background_image.draw(0, 0, 0)
    @draws += 1
    # x, y, z, scale_x, scale_y
    @character.draw(@x, @y, 1, 0.15, 0.15)
  end

end

window = GameWindow.new
window.show
