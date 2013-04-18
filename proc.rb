class NyaProc
  def initialize(params, body,closure)
    @params = params
    @body = body
    @closure = closure
  end
  
  def call(context, arguments)
    # It's a method call
    if context.kind_of? NyaObject
      
      context = Context.new(context)
    else 
    #It's a lambda call 
    context.locals = context.locals.merge @closure
    end
    @params.each_with_index do |param, index|
      context.locals[param] = arguments[index]
    end
    @body.eval(context)
  end
end

