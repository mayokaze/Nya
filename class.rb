class NyaClass < NyaObject
  attr_reader :runtime_methods, :class_attrs
  attr_accessor :base_class
 
  
  def initialize(base=nil)
    @runtime_methods = {}
    @class_attrs = {}
    @base_class=base
    
    #To solve chicken-egg problem
    if defined?(Runtime)
      runtime_class = Runtime["Class"]
      @base_class= Runtime["Class"] unless @base_class
    else
      runtime_class = nil
    end
  
    super(runtime_class)
  end

  
  def lookup(method_name)
    method = @runtime_methods[method_name]
    if !method and @base_class != Runtime["Class"]
       method = @base_class.lookup(method_name)
    end
    method  
  end

 
  def new
    attrs = @class_attrs.clone
    NyaObject.new(self,attrs)
 end
  

  def new_with_value(value)
    attrs = @class_attrs.clone
    NyaObject.new(self,attrs,value)
  end
end