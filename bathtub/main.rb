# main.rb

require 'sdl'
require 'bathtub/game.rb'

class Main
  
  TITLE = "バスタブ一直線"
  VERSION = "0.51"
  
  def initialize(fullscreen=false)
    SDL.init(SDL::INIT_VIDEO|SDL::INIT_AUDIO|SDL::INIT_JOYSTICK)
    SDL::TTF.init
    SDL::Mixer.open
    
    SDL::WM.icon = SDL::Surface.loadBMP("image/icon-16168.bmp")
    #screen
    if fullscreen
      screen = SDL::setVideoMode(640,480,16,SDL::SWSURFACE|SDL::FULLSCREEN) #|SDL::DOUBLEBUF
      SDL::Mouse.hide
    else
      screen = SDL::setVideoMode(640,480,16,SDL::SWSURFACE) #|SDL::DOUBLEBUF)
    end
    #SDL::WM.setCaption(TITLE+" "+VERSION, TITLE)
    
    #init game
    @game = Game.new(screen)
  end

  def run
    @game.run
  end
  
end

