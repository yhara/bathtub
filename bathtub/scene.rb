#
# scene.rb
#

class GameMain
  extend SingleTask
  
  def init
    Sound.open(:bgm, "blacksamba.it")
    Sound.open(:bgm2, "clambient.it")
    @mode = nil
  end
  attr_accessor :mode
  
  class << GameMain
    def set_mode(mode);   self.instance.mode = mode;   end
    def mode;             self.instance.mode;          end
  end
    
  def enabled
    (@mode==:endless) ? Sound.play(:bgm2) : Sound.play(:bgm)
    Bath.enable
    Jumpers.enable
    TaskManager.reset
  end
  
  def disabled
    Sound.stop_music
    Jumpers.disable
  end
  
  def act(dt,i)
    if @mode==:endless && i.keydown.esc
      GameMain.disable
      Gameover.enable
    end
  end
  
end

class ModeSelect
  extend SingleTask
  
  MODES = [:easy, :normal, :endless]
  HEIGHT = [180,220,260]
  LEFT = 100
  
  def init
    @font=SDL::TTF.open("image/boxfont2.ttf", 40)
    @movetimer = Timer.new(100)
    @cur = 0
  end
  
  def enabled
    Highscore.enable
    Highscore.instance.show = MODES[@cur]
  end
  
  def act(dt,i)
    if i.keydown.left
      @cur-=1
      @cur = MODES.size-1 if @cur<0
      Highscore.instance.show = MODES[@cur]
    elsif i.keydown.right
      @cur+=1
      @cur = 0 if @cur>MODES.size-1
      Highscore.instance.show = MODES[@cur]
    elsif i.keydown.button
      self.disable
      Highscore.disable
      GameMain.set_mode(MODES[@cur])
      GameMain.enable
    end
  end
  
  def draw(i)
    @font.drawBlendedUTF8(i.scr, "  EASY",    LEFT,HEIGHT[0], 0,0,0)
    @font.drawBlendedUTF8(i.scr, "  NORMAL",  LEFT,HEIGHT[1], 0,0,0)
    @font.drawBlendedUTF8(i.scr, "  ENDLESS", LEFT,HEIGHT[2], 0,0,0)
    @font.drawBlendedUTF8(i.scr, "*",         LEFT,HEIGHT[@cur], 0,0,0)
  end
  
end

class Gameover
  extend SingleTask
  
  def init
    @font = SDL::TTF.open("image/boxfont2.ttf", 48)
    @flashtimer = Timer.new(700)
    @draw = true
  end
  
  def act(dt,i)
    @flashtimer.wait(dt){
      @draw = (@draw ? false : true)
    }
    if i.keydown.button
      i.keydown.reset
      self.disable
      Bath.disable
      newscore = (GameMain.mode==:endless ? i.score.max : i.score.value)
      if Highscore.instance.high?(newscore)
        NameEntry.enable
      else
        ModeSelect.enable
      end
    end
  end
  
  def draw(i)
    @font.drawBlendedUTF8(i.scr,"HIT ENTER KEY", 160,220 , 0,0,0) if @draw
  end
  
end

class NameEntry
  extend SingleTask
  
  CHARS = []
  26.times{|i| CHARS << ?A+i}
  10.times{|i| CHARS << ?0+i}
  CHARS << -1 # 'BS'
  CHARS << -2 # 'END'
  
  R = 160
  BASE = Math::PI / 2
  RAD = Math::PI * 2 / CHARS.size
  
  def init
    @font_small = SDL::TTF.open("image/curving.ttf", 10)
    @font       = SDL::TTF.open("image/curving.ttf", 24)
    @font_big   = SDL::TTF.open("image/curving.ttf", 30)
    @waittimer = Timer.new(100)
    @name = ""
    @cur = 0
  end
  
  def enabled
    Bath.enable
    Jumpers.disable
  end
  
  def act(dt,i)
    if i.keydown.other
      i.keydown.other.each do |sym|
        case sym
        when SDL::Key::BACKSPACE, SDL::Key::DELETE
          @name.chop!
        when (SDL::Key::A..SDL::Key::Z)
          if sym==SDL::Key::H && i.key.ctrl
            @name.chop!
          else
            @cur = sym - SDL::Key::A
            @name << (?A + @cur).chr
          end
        when (SDL::Key::K0..SDL::Key::K9)
          @cur = sym - SDL::Key::K0
          @name << (?0 + @cur).chr
        when (SDL::Key::KP0..SDL::Key::KP9)
          @cur = sym - SDL::Key::KP0
          @name << (?0 + @cur).chr
        end
      end
    end
    
    if i.keydown.button
      case CHARS[@cur]
      when -1 # BS
        @name.chop!
      when -2 # END
        newscore = (GameMain.mode==:endless ? i.score.max : i.score.value)
        Highscore.instance.add( newscore, @name.dup )
        self.disable
        Bath.disable
        ModeSelect.enable
      else
        if i.keydown.other && i.keydown.other.include?(SDL::Key::RETURN)
          @cur = CHARS.size-1
        else
          @name << CHARS[@cur].chr
        end
      end
    end
    
    @waittimer.wait(dt){
      if i.key.left
        @cur -= 1
        @cur = CHARS.size-1 if @cur<0
      elsif i.key.right
        @cur += 1
        @cur = 0 if @cur>CHARS.size-1
      end
    }
  end
  
  def draw(i)
    CHARS.each_with_index do |c,n|
      x = 320 + (R * Math.sin(RAD*(n-@cur)))
      y = 200 + (R * Math.cos(RAD*(n-@cur)))
      color = (n==@cur) ? [255,80,80] : [80,80,80]
      
      if c==-1 # BS
        @font_small.drawBlendedUTF8(i.scr, "D", x,y       , *color)
        @font_small.drawBlendedUTF8(i.scr, "E", x+5,y+5   , *color)
        @font_small.drawBlendedUTF8(i.scr, "L", x+10,y+10 , *color)
      elsif c==-2 # END
        @font_small.drawBlendedUTF8(i.scr, "E", x,y       , *color)
        @font_small.drawBlendedUTF8(i.scr, "N", x+5,y+5   , *color)
        @font_small.drawBlendedUTF8(i.scr, "D", x+10,y+10 , *color)
      elsif n==@cur
        @font_big.drawBlendedUTF8(i.scr, c.chr, x,y , *color)
      else
        @font.drawBlendedUTF8(    i.scr, c.chr, x,y , *color)
      end
    end
    
    x = 320 - @font_big.textSize(@name).first / 2
    @font_big.drawBlendedUTF8(i.scr, @name, x,192 , 255,80,80)
  end
  
end

