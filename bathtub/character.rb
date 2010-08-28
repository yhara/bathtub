#
# character.rb
#

class Combo
  include Task
  
  def self.load
    @@font = SDL::TTF.open("image/curving.ttf", 20)
  end
  attr_accessor :x,:y,:value
  
  def init
    @step = 0
  end
  
  def act(dt,i)
    @step += dt
    @active = false if @step > 500
  end
    
  def draw(i)
    @@font.drawBlendedUTF8(i.scr,"#{@value} COMBO", @x,@y-(@step/10) , 255,100,100)
  end
  
end

class Bath
  extend SingleTask
  
  Shibuki = Struct.new(:x,:y,:step)
  
  WAIT_STAFF_ANIM = 80
  MOVE_WAIT = 3
  
  STAFF_IMGS = 4
  SHIBUKI_IMGS = 3
  Y0  = 342
  
  attr_reader :x,:y
  
  def init
    @img_bath = SDL::Surface.loadBMP("image/bath.bmp")
    @img_bath.setColorKey(SDL::SRCCOLORKEY,[255,0,255])
    @img_rstaff = Util.cut_image(56,67,STAFF_IMGS, SDL::Surface.loadBMP("image/staff.bmp"), 0,0,  [255,0,255])
    @img_lstaff = Util.cut_image(56,67,STAFF_IMGS, SDL::Surface.loadBMP("image/staff.bmp"), 0,67, [255,0,255])
    @img_shibuki = Util.cut_image(94,105,SHIBUKI_IMGS, SDL::Surface.loadBMP("image/shibuki.bmp"),0,0,[255,255,255])
    Sound.open(:scratch, "BB_Scratch_19.wav", 40)
    @movetimer = Timer.new(MOVE_WAIT)
    @staff_anim_timer = Timer.new(WAIT_STAFF_ANIM)
    @shibuki_timer = Timer.new(80)
  end
  
  def enabled
    @movestep = (GameMain.mode==:endless ? 3 : 2)
  end
  
  def reset
    @staffimg = 0
    @x = 320 #バスタブの中心座標
    @y = Y0
    @dir = 1 #1:right -1:left
    @effects = []
  end

  def shibuki
    @effects << Shibuki.new(0,0,0)
  end
  
  def act(dt,i)
    act_move(dt,i) unless Gameover.active?
    act_shibuki(dt)
  end
  
  def act_move(dt,i)
    if i.key.right 
      newdir = 1
    elsif i.key.left
      newdir = -1
    elsif i.keydown.button
      newdir = -@dir
    else
      newdir = @dir
    end
    
    if newdir != @dir
      #Sound.play(:scratch)
      @dir = newdir
    end
      
    @staff_anim_timer.wait(dt){
      @staffimg+=1
      @staffimg=0 if @staffimg>=STAFF_IMGS
    }
    
    @movetimer.wait(dt){
      @x += @dir * @movestep
      @x = 0 if @x<0
      @x = 639 if @x>639
    }
  end
  
  def act_shibuki(dt)
    @effects.each do |eff|
      @shibuki_timer.wait(dt){
          eff.step+=1
      }
    end
    @effects.delete_if{|eff|
      eff.step >= SHIBUKI_IMGS
    }
  end

  def draw(i)
    @effects.each{|eff| i.scr.put(@img_shibuki[eff.step], @x-55, @y-58)}
    
    @x = 330 if NameEntry.active?
    
    i.scr.put(@img_lstaff[@staffimg], @x-80, @y-14)
    i.scr.put(@img_bath,              @x-37, @y   )
    i.scr.put(@img_rstaff[@staffimg], @x+32, @y-14)
  end

end


class Jumper
  include Task
  
  def self.load
    @@img = SDL::Surface.loadBMP("image/hito.bmp")
    @@img.setColorKey(SDL::SRCCOLORKEY,[255,0,255])
  end
  
  attr_accessor :x,:y
  def init
    case GameMain.mode
    when :easy
      speed = 11
    when :normal
      speed = 8
    when :endless
      speed = 7
    end

    @movetimer = Timer.new(speed)
    @type = rand(2)
    @missed = false

    #座標関連
    @t0=-20
    @y0=260
    @x=(@type==0 ? 0 : 640)
    @y=0
    @t=0
    @vx=rand(6)+1
  end
  attr_accessor :missed

  def act(dt,info)
    @movetimer.wait(dt){
      @t+=0.8
      if @type==0
        @x = @vx*@t
      else # @type==1
        @x = 640 - @vx*@t
      end

      @y = 480 - ( @y0 + 10*(@t-@t0) - 0.1*(@t-@t0)*(@t-@t0) )
    }
    
    if @x<0 || @x>=640 || @y>=480
      @alive = false
    end
  end
  
  def draw(i)
    i.scr.put(@@img, @x - @@img.w/2, @y)
  end
  
end

class Jumpers
  extend SingleTask
  
  def init
    Sound.open(:zabun, "SplashA1@22.wav", 60)
    Sound.open(:fall,  "fall.wav", 60)
  end

  def reset
    @items = []
    @margin = (GameMain.mode==:easy ? 80 : 25)
  end
  
  def act(dt,i)
    ret = 0 #0pts
    
    #生成
    if @items.size<1 && !Gameover.active?
      @items << Jumper.new
    end

    #動く
    @items.each do |item|
      if item.y>=330 && item.alive && !item.missed
        #判定
        if (Bath.instance.x-item.x).abs < @margin
          #ざっぱーん
          item.alive = false #棄てる
          i.score.incr #1 pts
          Sound.play(:zabun)
          Bath.instance.shibuki
          if GameMain.mode==:endless && i.score.value > 0
            c = Combo.new
            c.x = Bath.instance.x; c.y = Bath.instance.y; c.value = i.score.value
          end
        elsif item.y>=360
          #あべし
          Sound.play(:fall)
          item.missed = true
          i.score.miss #1miss
        end
      end
    end
    
    #削除
    @items.delete_if{|item| !item.alive}
  end

end

