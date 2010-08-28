#
# misc.rb
#

class Consts
  LIVES = 2
end

#----------------------------------------------------------------------------------

class Timer
  def reset
    @ct=0
  end

  def initialize(waittime)
    set_wait(waittime)
    reset
  end

  def wait(dt)
    @ct+=dt
    while @ct>=@waittime do
      @ct-=@waittime
      yield
      @ct=0 if @ct<@waittime
    end
  end

  def set_wait(t)
    raise ArgumentError,"waittime must be positive" if t<=0
    @waittime = t
  end
end

#----------------------------------------------------------------------------------
module Sound

  class << Sound
    def open(sym,fname,vol=nil)
      if fname=~/\.wav\z/
        @@waves ||= {}
        @@waves[sym] = [SDL::Mixer::Wave.load("sound/"+fname), @@waves.size]
        @@waves[sym][0].setVolume(vol) if vol
      else
        @@bgm ||= {}
        #@@bgm[sym] = SDL::Mixer::Music.load("sound/"+fname)
      end
    end

    def play(sym)
      if @@waves.key? sym
        SDL::Mixer.playChannel(@@waves[sym][1],  #channel
        @@waves[sym][0],  #wave
        0)
      else
        #SDL::Mixer.playMusic(@@bgm[sym],-1)
      end
    end

    def stop_music
      SDL::Mixer.haltMusic
    end
  end

end

#------------------------------------------------------------------------------
module Util
  def self.cut_image(w,h,n,img, ofsx=0, ofsy=0, colkey=nil)
    ret = []
    n.times do |i|
      surf = img.copyRect(i*w+ofsx,0+ofsy, w,h)
      surf.setColorKey(SDL::SRCCOLORKEY, colkey) if colkey!=nil
      ret << surf
    end
    ret
  end
end


#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
