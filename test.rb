require "rsec"
include Rsec::Helpers



x = ARGV[0] ?  (File.read ARGV[0]) : puts('need a file name')  

p seq("\n", /\ */).eof.parse! x