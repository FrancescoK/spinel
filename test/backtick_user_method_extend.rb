# A ` (or any method) from a module that main extends answers bare calls
# where self is main. Elsewhere self has no such method: a backtick runs
# the command, and any other name raises NoMethodError.
module M
  def `(c) = c.size
  def label(c) = "M #{c}"
end
extend M

class K
  def run = `echo k`
  def self.crun = `echo c`
  def other = label("k")
end

def top = `echo top`

p `echo hi`
p top
x = 0
3.times { x += `echo ab` }
p x
p %x(echo #{x}) + 1
p K.new.run
p K.crun
p "s".instance_eval { `echo s` }
p label("main")
begin
  K.new.other
rescue NoMethodError => e
  p e.class
end

# main's singleton class (the extend) comes before Object (an include)
module First
  def tag = "extend"
end
module Second
  def tag = "include"
end
extend First
include Second
p tag
class K
  def tag_here = tag
end
p K.new.tag_here
