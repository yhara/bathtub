require 'singleton'
require 'bathtub/misc.rb'
require 'bathtub/task.rb'
require 'bathtub/score.rb'
require 'bathtub/scene.rb'
require 'bathtub/graphic.rb'
require 'bathtub/character.rb'

class NullJoystick
  def axis(a); 0; end
  def hat(i);  0; end
  def numButtons; 0; end
end

class Game
  
  Key = Struct.new(:left,:right,:button,:other,:ctrl,:esc)
  class Key
    def reset
      self.size.times{|i| self[i]=nil}
    end
  end
  
  def initialize(screen)
    @screen = screen
    @joy = (SDL::Joystick.num > 0) ? SDL::Joystick.open(0) : NullJoystick.new
    
    TaskManager.init
    
    Background.new
    Gameover.disable
    Highscore.disable
    ModeSelect.enable
    GameMain.disable
    @score = Score.instance
    Jumper.load
    Jumpers.disable
    Bath.disable
    Combo.load
    NameEntry.disable
  end
  
  def run
    TaskManager.reset
    before = now = SDL.getTicks
    info = Task::Info.new
    info.scr = @screen
    info.score = @score
    info.key = Key.new
    info.keydown = Key.new
    
    while true
      return if check_events(info.key, info.keydown)==nil
      
      before=now; now=SDL.getTicks; dt=now-before
      TaskManager.act(dt,info)

      TaskManager.draw(info)
      @screen.flip
    end
  end
  
  def check_events(key,kd)
    key.reset
    kd.reset
    
    #check keys
    while (event=SDL::Event2.poll)
      case event
      when SDL::Event2::Quit
        return nil
      when SDL::Event2::JoyButtonDown
        kd.button = true
      when SDL::Event2::JoyAxis
        if event.value < -512
          kd.left = true
        elsif event.value > 512
          kd.right = true
        end
      when SDL::Event2::KeyDown
        kd.other ||= []
        kd.other << event.sym
        case event.sym
        when SDL::Key::ESCAPE
          if GameMain.mode==:endless && GameMain.active?
            kd.esc = true
          else
            return nil
          end
        when SDL::Key::RETURN, SDL::Key::SPACE
          kd.button = true
        when SDL::Key::LEFT, SDL::Key::UP, SDL::Key::H, SDL::Key::K
          kd.left = true
        when SDL::Key::RIGHT, SDL::Key::DOWN, SDL::Key::L, SDL::Key::J
          kd.right = true
        end
      end
    end
    
    SDL::Key.scan; SDL::Joystick.updateAll
    key.left  = true if @joy.axis(0) < -512 || @joy.axis(1) < -512 ||
                        @joy.hat(0) == SDL::Joystick::HAT_LEFT ||  @joy.hat(0) == SDL::Joystick::HAT_UP
    key.right = true if @joy.axis(0) >  512 || @joy.axis(1) >  512 ||
                        @joy.hat(0) == SDL::Joystick::HAT_RIGHT || @joy.hat(0) == SDL::Joystick::HAT_DOWN
    @joy.numButtons.times{|i| key.button = true if @joy.button(i)}
    [SDL::Key::RETURN, SDL::Key::SPACE].each{|k| key.button=true if SDL::Key.press?(k)}
    [SDL::Key::LEFT, SDL::Key::UP].each{|k| key.left=true  if SDL::Key.press?(k)}
    [SDL::Key::RIGHT, SDL::Key::DOWN].each{|k| key.right=true if SDL::Key.press?(k)}
    unless NameEntry.active?
      [SDL::Key::H, SDL::Key::K].each{|k| key.left=true  if SDL::Key.press?(k)} 
      [SDL::Key::L, SDL::Key::J].each{|k| key.right=true if SDL::Key.press?(k)}
    end
    key.ctrl = true if SDL::Key.press?(SDL::Key::LCTRL)
    
    return true
  end
  
end


