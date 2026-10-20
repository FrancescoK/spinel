# Unary + of a call that answers a String literal is a new String each time,
# as +"lit" is: the literal is frozen. Two of them changed in place were
# refused as a route that cannot carry the handle (#9258). A method that may
# answer a String a variable holds is no such call: + answers that String.

def inner = "lit"
y = (+inner).force_encoding("UTF-8")
z = (+inner).force_encoding("UTF-8")
y << "1"
p y, z, inner

class Tag
  def word = "tag"
  def build = (+word) << "!"
end
t = Tag.new
a = t.build
b = t.build
a << "?"
p a, b, t.word

$held = +"held"
def maybe(k) = k ? "lit" : $held
m = +maybe(false)
m << "*"
p m, $held, m.equal?($held)
