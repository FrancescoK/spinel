# spinel: reject-subclass: a method redefined by a later reopening of its class is called between the two definitions on a value whose class is known only at run time
# B#get is defined again by a later reopening of B; the call between the two
# definitions is on a value that may be a B or a C, so which definition it
# reaches is decided by its class at run time: refused, not answered with the
# later body (CRuby prints 1, then 2)
class B
  def get = 1
end
class C
  def get = 3
end
x = ARGV.empty? ? B.new : C.new
p x.get
class B
  def get = 2
end
p x.get
