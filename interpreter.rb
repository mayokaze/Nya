require "parser"
require "runtime"

class Interpreter
  def initialize
    @parser = Parser.new
  end
  
  def eval(code)
    @parser.run(code).eval(Runtime)
  end
end

class Nodes
  def eval(context)
    return_value = nil
    nodes.each do |node|
      return_value = node.eval(context)
    end
    return_value || Runtime["nil"]
  end
end

class NumberNode
  def eval(context)
    Runtime["Number"].new_with_value(value)
  end
end

class StringNode
  def eval(context)
    Runtime["String"].new_with_value(value)
  end
end

class TrueNode
  def eval(context)
    Runtime["true"]
  end
end

class FalseNode
  def eval(context)
    Runtime["false"]
  end
end

class NilNode
  def eval(context)
    Runtime["nil"]
  end
end

class CallNode
  def eval(context)
    #Access local variable
    if receiver.nil? && context.locals[method] && arguments.empty?
      context.locals[method]
    
    # Proc call
    else
      if receiver
        value = receiver.eval(context)
      else
        value = context.current_self
      end
      eval_arguments = arguments.map { |arg| arg.eval(context) }
      value.call(method,context,eval_arguments)#Lambda call needs the context,while method call needs the receiver information
    end
  end
end

class GetConstantNode
  def eval(context)
    context[name]
  end
end

class SetConstantNode
  def eval(context)
    context[name] = value.eval(context)
  end
end



class SetLocalNode
  def eval(context)
    context.locals[name] = value.eval(context)
  end
end

class DefNode
  def eval(context)
    # Define a method under a class enviroment or nested function or top level
    method = NyaProc.new(params, body,nil)
    context.current_class.runtime_methods[name] = method
  end
end

class LambdaNode
  def eval(context)
     NyaProc.new(params, body,context.locals)
  end
end

class GetAttrNode
  def eval(context)
    if context.current_self.kind_of? NyaClass
      context.current_class.class_attrs[name] = Runtime["nil"]
   else
     context.current_self[name]
   end
 end
end

class SetAttrNode
  def eval(context)
    if context.current_self.kind_of? NyaClass
      context.current_class.class_attrs[name] = value.eval(context)
   else
     context.current_self[name]=value.eval(context)
    end
 end
end

class ClassNode
  def eval(context)
    # class reopen
    nya_class = context[name]
    
    unless nya_class 
      if base and base_class = context[base]
       nya_class = NyaClass.new(base_class)
      else 
        nya_class = NyaClass.new
      end  
     context[name] = nya_class
    end
    
    #Evaluate the body of class, everything defined inside the class will have the class context
    class_context = Context.new(nya_class, nya_class)
    
    body.eval(class_context)
    
    nya_class
  end
end

class IfNode
  def eval(context)
    if condition.eval(context).ruby_value
      body.eval(context)
    end
  end
end

class WhileNode
  def eval(context)
    while condition.eval(context).ruby_value
      body.eval(context)
    end
  end
end

class UnlessNode
  def eval(context)
    unless condition.eval(context).ruby_value
      body.eval(context)
    end
  end
end