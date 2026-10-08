# A Method bound to a String's in-place mutator, in a program where another
# class defines its own `method`: that method is not what a String's
# `.method` reaches, so the call is still refused, naming the line (it
# crashed).
# spinel: reject-string-method
class Foo
  def method(x) = x
end
p Foo.new.method(3)
s = +"abc"
t = s
s.method(:<<).call("!")
p t
