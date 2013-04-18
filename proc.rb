class NyaProc
  def initialize(params, body,closure)
    @params = params
    @body = body
    @closure = closure
  end
  
  def call(env, arguments)
    # It's a method call
    if env.kind_of? NyaObject
      
      env = Env.new(env)
    else 
    #It's a lambda call 
    env.locals = env.locals.merge @closure
    end
    @params.each_with_index do |param, index|
      env.locals[param] = arguments[index]
    end
    @body.eval(env)
  end
end

