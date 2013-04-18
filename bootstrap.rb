nya_class = NyaClass.new            
nya_class.runtime_class = nya_class 
nya_class.base_class = nya_class   
object_class = NyaClass.new            
object_class.runtime_class = nya_class  
object_class.base_class = nya_class

Runtime = Context.new(object_class.new)

Runtime["Class"] = nya_class
Runtime["Object"] = object_class
Runtime["Number"] = NyaClass.new
Runtime["String"] = NyaClass.new


Runtime["TrueClass"] = NyaClass.new
Runtime["FalseClass"] = NyaClass.new
Runtime["NilClass"] = NyaClass.new

Runtime["true"] = Runtime["TrueClass"].new_with_value(true)
Runtime["false"] = Runtime["FalseClass"].new_with_value(false)
Runtime["nil"] = Runtime["NilClass"].new_with_value(nil)
Runtime["Kernel"] = Runtime["Object"].new


Runtime["Class"].runtime_methods["new"] = proc do |receiver, arguments| #Define new
  receiver.new
end

Runtime["Object"].runtime_methods["get_slot"] = proc do |receiver, arguments| 
  receiver[ arguments[0].ruby_value]
end
Runtime["Object"].runtime_methods["set_slot"] = proc do |receiver, arguments| 
  receiver[arguments[0].ruby_value] = arguments[1]
end
Runtime["Object"].runtime_methods["clone"] = proc do |receiver, arguments| 
   obj =  receiver.clone
   obj.obj_attrs = receiver.obj_attrs.clone
   obj.ruby_value = receiver.ruby_value.clone
   obj.runtime_class= receiver.runtime_class.clone
   obj
end

Runtime["Number"].runtime_methods["+"]= proc do |receiver,arguments| 
 result = receiver.ruby_value + arguments.first.ruby_value
 Runtime["Number"].new_with_value(result)
end
Runtime["Number"].runtime_methods["*"]= proc do |receiver,arguments| 
 result = receiver.ruby_value * arguments.first.ruby_value
 Runtime["Number"].new_with_value(result)
end
Runtime["Number"].runtime_methods["/"]= proc do |receiver,arguments| 
 result = receiver.ruby_value / arguments.first.ruby_value
 Runtime["Number"].new_with_value(result)
end
Runtime["Number"].runtime_methods["%"]= proc do |receiver,arguments| 
 result = receiver.ruby_value % arguments.first.ruby_value
 Runtime["Number"].new_with_value(result)
end
Runtime["Number"].runtime_methods["-"]= proc do |receiver,arguments| 
 result = receiver.ruby_value - arguments.first.ruby_value
 Runtime["Number"].new_with_value(result)
end
Runtime["Number"].runtime_methods[">"]= proc do |receiver,arguments| 
 result = receiver.ruby_value > arguments.first.ruby_value
  if result
    Runtime["true"]
  else
    Runtime["false"]
  end
end

Runtime["Number"].runtime_methods["<"]= proc do |receiver,arguments| 
 result = receiver.ruby_value < arguments.first.ruby_value
  if result
    Runtime["true"]
  else
    Runtime["false"]
  end
end

Runtime["Number"].runtime_methods["=="]= proc do |receiver,arguments| 
 result = receiver.ruby_value == arguments.first.ruby_value
  if result
    Runtime["true"]
  else
    Runtime["false"]
  end
end

Runtime["TrueClass"].runtime_methods["&&"]= proc do |receiver,arguments| 
  result = receiver.ruby_value && arguments.first.ruby_value 
   if result
     Runtime["true"]
   else
     Runtime["false"]
   end
end

Runtime["TrueClass"].runtime_methods["\|\|"]= proc do |receiver,arguments| 
     Runtime["true"]
   end
Runtime["FalseClass"].runtime_methods["\|\|"]= proc do |receiver,arguments| \
  result = receiver.ruby_value || arguments.first.ruby_value
    if result
      Runtime["true"]
    else
      Runtime["false"]
  end
 end

Runtime["FalseClass"].runtime_methods["&&"]= proc do |receiver,arguments| 
  Runtime["false"]
end


Runtime["Object"].runtime_methods["print"] = proc do |receiver, arguments|
  puts arguments.first.ruby_value
  Runtime["nil"]
end


