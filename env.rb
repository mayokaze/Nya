
class Env
  attr_reader  :current_self, :current_class
  attr_accessor :locals
  

  @@constants = {}
  
  def initialize(current_self, current_class=current_self.runtime_class)
    #p "test"
    @locals = {}
    @current_self = current_self
    @current_class = current_class
  end
  

  def [](name)
    @@constants[name]
  end
  def []=(name, value)
    @@constants[name] = value
  end
end
