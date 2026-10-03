# `x.to_json(...)` on a value that is a user object or a builtin only at
# run time: the user class's own #to_json takes the arguments as given,
# whatever its signature, and a builtin's takes an optional state and
# raises ArgumentError past it. The call went to the generator for every
# value, which called a user #to_json only in two shapes and dropped the
# arguments, and never checked the count.
require "json"
class Q
  def to_json(a = nil, b = nil, c = nil) = "q#{a.inspect}#{b.inspect}#{c.inspect}"
end
class R
  def to_json(*args) = "r#{args.size}"
end
class S
  def initialize(v) = @v = v
  def to_s = "s#{@v}"
end
vals = [Q.new, R.new, 1, "str", [1, 2], {k: 1}, nil]
vals.each do |x|
  p x.to_json
  p x.to_json(nil)
  begin
    p x.to_json(1, 2)
  rescue ArgumentError => e
    p e.message
  end
end
[S.new(1), Q.new].each { |x| p x.to_json }
p JSON.generate([1, "a"])
