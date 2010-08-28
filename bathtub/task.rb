#
# task.rb
#

class TaskManager
  
  class << TaskManager
    def init
      @@task = []
    end

    def add_task(t)
      @@task << t
    end

    def reset
      @@task.each{|t| t.reset}
    end
    def draw(info)
      @@task.each{|t| t.draw(info) if t.active?}
    end
    def act(dt,info)
      @@task.each{|t| t.act(dt,info) if t.active?}
      @@task.delete_if{|t| !t.alive}
    end
  end
  
end

module Task
  Info = Struct.new(:key,:keydown,:scr,:score)
  
  def initialize
    @active = true
    @alive = true
    TaskManager.add_task(self)
    init
  end
  attr_accessor :alive
  
  def active?;  @active;                   end
  def enable;   @active = true;  enabled;  end
  def disable;  @active = false; disabled; end
  
  def enabled;  end
  def disabled; end
  
  def init; end
  def act(dt,info); end
  def draw(info); end
  def reset; end
end

module SingleTask
  def self.extended(klass)
    klass.__send__ :include, Singleton
    klass.__send__ :include, Task
  end
  
  def active?;  self.instance.active?;  end
  def enable;   self.instance.enable;   end
  def disable;  self.instance.disable;  end
end
