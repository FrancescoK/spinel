# A reopening's own StringIO#<< is the one a boxed StringIO takes, not the
# binding's (the arm that calls the binding stands aside for it).
require "stringio"
class StringIO
  def <<(x) = (write("[#{x}]"); self)
end
o = [1, StringIO.new(+"")][1]
o << "boxed" << "twice"
p o.string
