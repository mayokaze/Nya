class NyaObject
  attr_accessor :runtime_class, :ruby_value, :obj_attrs

 def initialize(runtime_class,attrs={},ruby_value=self)
    @runtime_class = runtime_class
    @ruby_value = ruby_value
    @obj_attrs = attrs
  end
  
  def [](name)
     @obj_attrs[name]
  end
  def []=(name, value)
     @obj_attrs[name] = value
  end
 
 def call(method, context,arguments=[])
   proc = @obj_attrs[method] #look up object slots
   if proc 
      proc.call(self, arguments)
  elsif proc = @runtime_class.lookup(method) #look up  class and base class
     # p @runtime_class if method == "lbd"
      proc.call(self, arguments)
  elsif proc = context.locals[method] #look up local functions,possible lambda expression with closure
      proc.call(context,arguments)
  elsif proc = Runtime["Object"].lookup(method) #look up top level functions
      proc.call(self,arguments)
  else
    raise "Method not found: #{method}"
  end    
 end
end