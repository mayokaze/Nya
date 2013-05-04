$:.unshift "."
require "rsec"
require "nodes"

class Parser
  include Rsec::Helpers
  extend Rsec::Helpers
  
  class Program < Array
  end    
  
  NUM       =  /\d+(\.\d+)?(e[\+\-]?\d+)?/i.r {|n|NumberNode.new(n.to_f)} 
  BOOL      =  word('true'){|n|BoolNode.new(true)} |word('false'){|n|BoolNode.new(false)} |word('nil'){|n| BoolNode.new(nil)} 
  #NEWLINE   = /\n/ .r * (1..-1)
  SPACE     = /\A\s*/.r 'space'
 
  ID        = /\A[a-z]\w*/.r 'id'
  CONST     = /\A[A-Z]\w*/.r 
  ATTR      = /\A@\w*/.r 
  STRING    = /\A\"(.*?)"/.r {|n|StringNode.new(n[1..n.length-2])}
  BRA    = symbol("{")
  KET    = symbol("}")
  OPA    = symbol("(")
  CPA    = symbol(")")
  CALL_OP = symbol(".")
  MUL_OP    = symbol(/[\*\/%]/).fail  'mul operator'
  ADD_OP    = symbol(/[\+\-]/).fail  'add operator'
  UN_OP = symbol(/(\+\+|\-\-|!)/).fail 'unary operator'
  BOOL_OP = symbol(/(&&|\|\|)/).fail  'bool operator'
  COMP_OP   = symbol(/(\<=|\>=|==|!=|\<|\>)/).fail 'compare operator'
  CLASS = word('class').fail 'class'
  DEF = word('def').fail 'def'
  IF = word('if').fail 'if'
  WHILE = word('while').fail 'while'
  UNLESS = word('unless').fail 'unless'

  

  def initialize
     
     terminator= seq_(';',SPACE)
    # symbol = ATTR.map{|n|GetAttrNode.new(n)}|ID|CONST.map{|n|GetConstantNode.new(n)}
     var = ATTR.map{|n|GetAttrNode.new(n)}|ID|CONST.map{|n|GetConstantNode.new(n)}
     atom = NUM|STRING|BOOL|var|seq_(OPA,lazy{expr},CPA).inner{|n|if (n[0])then n[0] end}
     alist = seq_(OPA, lazy{expr}.join(',') , CPA).inner.maybe{|n|if(n[0]) then
       n[0][0].delete(',');n[0][0]#.map{|i|p i;i[0]}
     else
       []
     end
     }
     
    gslot = BOOL|seq_(atom,'[',atom,']'){|n|if(n[0].kind_of? String) then
      r = CallNode.new(nil,n[0],[])
    else
      r = n[0]
    end    
  CallNode.new(r, "get_slot", [n[2]])}
    sslot = seq_(atom,'[',atom,']','=',lazy{expr}){|n|if(n[0].kind_of? String) then
      r = CallNode.new(nil,n[0],[])
    else
      r = n[0]
    end    
      CallNode.new(r, "set_slot", [n[2]]<<n[5])}
      
  call = gslot|seq_(ID,alist,lazy{call2}){|n|if(n[2]) then
       r = n[2]
       r = r.receiver while (r.receiver) 
       r.receiver = CallNode.new(nil,n[0],n[1])
       n[2]
     else
      CallNode.new(nil,n[0],n[1])
     end
   }|seq_(var,lazy{call2}){|n|if(n[1]) then
       r = n[1]
       r = r.receiver while (r.receiver) 
       r.receiver = n[0]
       n[1]
     else
       n[0] 
     end
     }|atom 
     
     call2 = seq_(CALL_OP,ID,alist,lazy{call2}).maybe{|n|if(n[0])then
       if(r = n[0][-1])
       r = r.receiver while (r.receiver) 
       r.receiver = CallNode.new(nil,n[0][1],n[0][2])
         n[0][-1]
      else
        CallNode.new(nil,n[0][1],n[0][2])
      end
     end
     }
     
  #   ss = seq_(call,'[',STRING,']','=',lazy{expr}){|n|CallNode.new(n[0], "set_slot",[n[2]]<<n[5])}
     
     #{|n|n[2]}
     #|seq_(seq_(ID,alist),message){|n|p "hello"}|
      
     #call  = seq_(ID,'.',ID,alist){|n|CallNode.new(n[0], n[2], n[3])}|seq(ID){|n| CallNode.new(nil, n[0], [])} 
     unary = seq_(call,UN_OP){|n|CallNode.new(n[0],n[1],[])}|seq_(UN_OP,call){|n|CallNode.new(n[1],n[0],[])}|call
     term = unary.join(MUL_OP){|p,*ps| ps.each_slice(2).inject(p) { |left, (op, right)| CallNode.new(left,op,[right])}}
     binary = term.join(ADD_OP){|p,*ps| ps.each_slice(2).inject(p) {|left, (op, right)| CallNode.new(left,op,[right])}}
     comp = binary.join(COMP_OP){|p,*ps| ps.each_slice(2).inject(p) {|left, (op, right)| CallNode.new(left,op,[right])}}
     bool = comp.join(BOOL_OP){|p,*ps| ps.each_slice(2).inject(p) {|left, (op, right)| CallNode.new(left,op,[right])}}
     #term = seq_(unary,MUL_OP,unary){|n|CallNode.new(n[0],n[1],n[2])}|unary
    # binary= seq_(term,ADD_OP,term){|n|CallNode.new(n[0],n[1],n[2])}|term
    # comp= seq_(binary,COMP_OP,binary){|n|CallNode.new(n[0],n[1],n[2])}|binary
    # bool = seq_(comp,BOOL_OP,comp){|n|CallNode.new(n[0],n[1],n[2])}|comp
     assign = seq_(ID,"=",lazy{expr}){|n|SetLocalNode.new(n[0], n[2])}|
     seq_(CONST,"=",lazy{expr}){|n|SetConstantNode.new(n[0], n[2])}|
     seq_(ATTR,"=",lazy{expr}){|n|SetAttrNode.new(n[0], n[2])}|sslot
     
     
     
  #   reciver =seq_(lazy{expr},'->')
 #    mexp = seq_(OPA, lazy{expr} , CPA).inner
  #   call = seq_(reciver,ID,alist){|n|p n; CallNode.new(n[0], n[1], n[2])}| 
  #   seq_(reciver,ID){|n|p n; CallNode.new(n[0], n[1], [])}|
   #  seq_(ID,alist){|n|p n;CallNode.new(nil, n[0], n[1])}|
  #   seq(ID){|n| CallNode.new(nil, n[0], [])} 
   
   

     
     plist = seq_(OPA, ID.join(',') , CPA).inner.maybe{|n|if n[0] then
      n[0][0].delete(',');n[0][0]
     else
       []
     end
     }
     define = seq_(DEF,ID,plist,lazy{block}){|n|
       DefNode.new(n[1], n[2], n[3])
     } 
     
     clazz = seq_(CLASS,CONST,lazy{block}){|val|
       ClassNode.new(val[1], val[2],nil) 
       }|seq_(CLASS,CONST,"<<",CONST,lazy{block}){|val|
       ClassNode.new(val[1], val[4],val[3]) 
       }
     lambda = seq_("\\",plist,lazy{block}){|n|LambdaNode.new(n[1],n[2])}
     
     expr = assign|bool|lambda
     ifs = seq_(IF,expr,lazy{block}){|n|IfNode.new(n[1], n[2])}
     whiles = seq_(WHILE,expr,lazy{block}){|n|WhileNode.new(n[1], n[2])}
     unlesss = seq_(expr,UNLESS,expr){|n|UnlessNode.new(n[2], n[0])}
    
     block = seq_(BRA, lazy{stmt}.star , KET).inner{|n|Nodes.new(n[0])}
      stmt = seq_(expr,terminator){|n|n[0]}|ifs|whiles|unlesss|define|clazz|terminator
     program = seq_(SPACE, lazy{stmt}.star){|n|Nodes.new(n[1])}#seq_(SPACE, block) {|p,*ps| Nodes.new(ps[0])}|
    @parser = program.eof#program.eof
 end
  
  def parse source
    res =  @parser.parse! source
   # p "test"
    p res
  # res.eval 
  end
end

#ARGV[0] ? Parser.new.run(File.read ARGV[0]) : puts('need a nya file name')  