# JSON.dump answers as CRuby's: an Integer second argument is a nesting
# limit (past it, ArgumentError "exceed depth limit"), an IO one gets the
# text and is the answer, no 100-level cap but that one, and NaN / Infinity
# written out -- where generate refuses them. The limit was dropped and NaN
# refused. And JSON held in a value (console's `@format = ::JSON`,
# `@format.dump(object, @depth_limit)`) reaches it: dump took one argument,
# so the module value's dispatch had no method to call with two.
require "json"
require "stringio"
deep = [[[[1]]]]
p JSON.dump(deep, 4)
begin; JSON.dump(deep, 3); rescue => e; p [e.class, e.message]; end
p JSON.dump(Float::NAN), JSON.dump([1.0 / 0, -1.0 / 0])
p JSON.dump({"a" => 1}), JSON.dump("x"), JSON.dump(nil), JSON.dump(1)
io = StringIO.new
r = JSON.dump([1, "two"], io)
p r.equal?(io), io.string
p (JSON.generate(Float::NAN) rescue $!.class)
class Safe
  def initialize(format: ::JSON, depth_limit: 2) = (@format = format; @depth_limit = depth_limit)
  def dump(o)
    @format.dump(o, @depth_limit)
  rescue ArgumentError => e
    "fallback: #{e.message}"
  end
end
p Safe.new.dump({"a" => [1, 2]}), Safe.new.dump({"a" => [[1]]})
