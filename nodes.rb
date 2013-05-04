require "object"
require "class"
require "proc"
require "env"
require "runtime"





class Nodes < Struct.new(:nodes)
  def <<(node)
    nodes << node
    self
  end
  
  def eval(env)
    return_value = nil
    nodes.each do |node|
      return_value = node.eval(env)
    end
    return_value || Runtime["nil"]
  end
end


class LiteralNode < Struct.new(:value); end
class NumberNode < LiteralNode
  def eval(env)
    Runtime["Number"].new_with_value(value)
  end
end
class StringNode < LiteralNode
  def eval(env)
    Runtime["String"].new_with_value(value)
  end
end

class BoolNode < LiteralNode
  def eval(env)
    Runtime["BoolClass"].new_with_value(value)
  end
end


class CallNode < Struct.new(:receiver, :method, :arguments)
  def eval(env)
    #Access local variable
    if receiver.nil? && env.locals[method] && arguments.empty?
      env.locals[method]
    
    # Proc call
    else
      if receiver
        value = receiver.eval(env)
      else
        value = env.current_self
      end
      eval_arguments = arguments.map { |arg| arg.eval(env) }
      value.call(method,env,eval_arguments)#Lambda call needs the env,while method call needs the receiver information
    end
  end
end


class GetAttrNode < Struct.new(:name)
  def eval(env)
    if env.current_self.kind_of? NyaClass
      env.current_class.class_attrs[name] = Runtime["nil"]
   else
     env.current_self[name]
   end
 end
end

class SetAttrNode < Struct.new(:name, :value)
  def eval(env)
    if env.current_self.kind_of? NyaClass
      env.current_class.class_attrs[name] = value.eval(env)
   else
     env.current_self[name]=value.eval(env)
    end
 end
end

class GetConstantNode < Struct.new(:name)
  def eval(env)
    env[name]
  end
end

class SetConstantNode < Struct.new(:name, :value)
  def eval(env)
    env[name] = value.eval(env)
  end
end
class DefNode < Struct.new(:name, :params, :body)
  def eval(env)
    # Define a method under a class enviroment or nested function or top level
    method = NyaProc.new(params, body,nil)
    env.current_class.runtime_methods[name] = method
  end

end

class LambdaNode < Struct.new(:params, :body)
  def eval(env)
     NyaProc.new(params, body,env.locals)
  end
end
class ClassNode < Struct.new(:name, :body,:base)
  def eval(env)
    # class reopen
    nya_class = env[name]
    
    unless nya_class 
      if base and base_class = env[base]
       nya_class = NyaClass.new(base_class)
      else 
        nya_class = NyaClass.new
      end  
     env[name] = nya_class
    end
    #Evaluate the body of class, everything defined inside the class will have the class env
    class_env = Env.new(nya_class, nya_class)
    body.eval(class_env)
    nya_class
  end
end
class SetLocalNode < Struct.new(:name, :value)
  def eval(env)
    env.locals[name] = value.eval(env)
  end
end

class IfNode  < Struct.new(:condition, :body)
  def eval(env)
    if condition.eval(env).ruby_value
      body.eval(env)
    end
  end
end

class WhileNode  < Struct.new(:condition, :body)
  def eval(env)
    while condition.eval(env).ruby_value
      body.eval(env)
    end
  end
end

class UnlessNode < Struct.new(:condition, :body)
  def eval(env)
    unless condition.eval(env).ruby_value
      body.eval(env)
    end
  end
end