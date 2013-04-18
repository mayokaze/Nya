require "parser"
require "object"
require "class"
require "proc"
require "env"
require "runtime"


class Interpreter
  def initialize
    @parser = Parser.new
  end
  
  def eval(code)
    @parser.parse(code).eval(Runtime)
  end
end