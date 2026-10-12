# An exception's #to_s that calls super answers the stored message: a read
# handed on as a variable's write is that String, changed in place through
# it as in CRuby.
class E < StandardError
  def to_s = super
end
s = +"src"
e = E.new(s)
m = e.message
m << "!"
p s, e.message, e.to_s
