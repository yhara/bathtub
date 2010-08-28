#
# score.rb
#

class Score
  extend SingleTask
  
  def init
    @font=SDL::TTF.open("image/boxfont2.ttf", 40)
  end
  
  def reset
    @life = Consts::LIVES
    @score = 0
    @max = 0
  end
  attr_accessor :score
  attr_reader :max
  
  def value
    @score
  end
  
  def incr
    @score+=1
    @max = @score if @max < @score
  end
  
  def miss
    if GameMain.mode==:endless
      @max = @score if @max < @score
      @score = 0
    else
      @life -= 1
      if @life < 0
        GameMain.disable
        Gameover.enable
        @life = 0
      end
    end
  end
  
  def draw(i)
    if GameMain.mode==:endless
      @font.drawBlendedUTF8(i.scr," LIFE: .. MAXCOMBO:#{'%3d' % @max}", 0,0 , 0,0,0)
    else
      lifemeter = '*'*@life + ' '*(Consts::LIVES-@life)
      @font.drawBlendedUTF8(i.scr," LIFE: #{lifemeter} SCORE:#{'%3d' % @score}", 0,0 , 0,0,0)
    end

  end
  
end


module Enumerable
  def stable_sort
    i = 0
    self.sort_by{|v| [v, i += 1]}
  end
end


class Highscore
  extend SingleTask
  
  N = 5
  FILE = "highscore.dat"
  
  def init
    @font = SDL::TTF.open("image/boxfont2.ttf", 25)
    @scores = read() || Hash.new
    ModeSelect::MODES.each do |mode|
      @scores[mode] ||= []
    end
    @show = nil
  end
  attr_reader :scores
  attr_writer :show
  
  def high?(score)
    p score, @scores
    return false if score==0
    mode = GameMain.mode
    @scores[mode].empty? || @scores[mode].size < N || @scores[mode].last[0] < score
  end
  
  def add(score,name)
    return unless high?(score)
    mode = GameMain.mode
    @scores[mode] << [score, name]
    @scores[mode] = @scores[mode].stable_sort.reverse[0,N]
    write
  end
  
  def read
    ret = nil
    if File.exist?(FILE)
      open(FILE,"rb") do |f|
        ret = Marshal.load(f)
      end
    end
    ret
  end
  
  def write
    open(FILE,"wb") do |f|
      Marshal.dump(@scores,f)
    end
  end
  
  def draw(i)
    @font.drawBlendedUTF8(i.scr, "* HighScore *",                380,38,        0,0,255)
    @scores[@show].each_with_index do |item,n|
      score,name = *item
      @font.drawBlendedUTF8(i.scr, "#{n+1}. #{score} (#{name})", 380,65+(20*n), 0,0,255)
    end
  end
  
end

