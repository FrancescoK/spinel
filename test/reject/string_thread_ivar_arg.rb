# An instance variable handed to a thread's block, which appends to it, and
# read in the method afterwards: refused, as the append would reach a copy.
class K
  def initialize = (@s = +"i")
  def go = (Thread.new(@s) { |t| t << "x" }.join; @s)
end
p K.new.go
