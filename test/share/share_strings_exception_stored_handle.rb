# spinel: share
# spinel: gc-minor
# Shared message reads return the exception's own stored object.
class OverriddenText < StandardError
  def to_s = "override"
end
class StoredText < StandardError; end
e = StoredText.new("v#{ARGV.size}")
a = e.message
b = e.message
a << "!"
b << "?"
p a.equal?(b), a, b

# Exception#to_s with no override of the class's own hands on the stored
# message, as #message does, while another class overrides it.
class Q < StandardError
  def to_s = "q"
end
class B < StandardError; end
src = +"src"
err = B.new(src)
a = err.message
a << "!"
t = err.to_s
p t.equal?(a)
u = err.to_s
u << "?"
p src, a
