# A method whose value is a String stored into a Hash (`h[k] = v`'s value),
# called on a receiver of more than one class, answers that String: the
# dispatch's arm read the method's handle into a plain String slot, where
# it was assigned bare and the C did not build. The String is the one the
# Hash holds, so a change through the answer shows in the Hash, also a
# mutator or a freeze called straight on it, and also where another
# class's arm answers a new String.
class Logger
  attr_reader :h

  def initialize = @h = {}

  def log_in
    @h["X"] = +"in"
  end

  def tag(k)
    @h[k] = +"tagged"
  end
end

class Local
  def log_in
    h = {}
    h["X"] = "local"
  end
end

o = [nil, Logger.new][1]
p o.log_in
p o.tag("Y")
p o.send(:log_in)
p o.public_send(("log_" + "in").to_sym)

r = o.log_in
r << "!"
p r
p o.h

t = o.tag("Z")
t << "?"
p o.h

l = [nil, Local.new][1]
p l.log_in

o.log_in.upcase!
p o.h["X"]
o.log_in.replace(+"q")
p o.h["X"]
o.log_in.gsub!(/i/) { "w" }
p o.h["X"]
o.tag("Y") << "!"
p o.h["Y"]
o.log_in.freeze
p o.h["X"].frozen?

class Fresh
  def log_in = +"fresh"
end

m = [Fresh.new, Logger.new][1]
m.log_in.upcase!
p m.h["X"]
m.log_in.freeze
p m.h["X"].frozen?
f = [Logger.new, Fresh.new][1]
p f.log_in
