#
# graphic.rb
#

class Background
  include Task
  
  def init
    @img_back = SDL::Surface.loadBMP("image/back.bmp")
    @img_logo = SDL::Surface.loadBMP("image/logo.bmp")
    @img_logo.setColorKey(SDL::SRCCOLORKEY,[0,0,255])
    @font = SDL::TTF.open("image/curving.ttf", 20)
  end
  
  def draw(i)
    i.scr.fillRect(0,0,640,480,0)
    i.scr.put(@img_back,0,0)
    if GameMain.active?
      i.scr.put(@img_logo,520,382)
      @font.drawBlendedUTF8(i.scr, GameMain.mode.to_s.upcase, 550,455, 255,80,80)
    end
  end
  
end

