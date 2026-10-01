# A block parameter that is the shared String handle (the String yielded to
# it is also shared with a lambda) is nil when a yield hands it nil or no
# argument, and so is a local written nil: the handle is NULL then. Read,
# it is nil, where taking its bytes crashed; appended to, it raises
# NoMethodError, where the append was dropped without a word, and so does
# a method called on it, where it crashed (#6179).
X = "x" * 100
f = ->(u) { u << "P" }
def r(f) = (z = +"z"; f.call(z); yield(z); yield(nil); yield; z.size)
p r(f) { |t| t << X if t }
r(f) { |t| p t }
r(f) { |t| p [t.nil?, t == nil, t.to_s, "<#{t}>", t&.size, t ? 1 : 0, t || "d"] }
r(f) { |t| begin; t << "!"; rescue NoMethodError => e; p e.message; end }
r(f) { |t| begin; t.concat("!"); rescue NoMethodError => e; p e.message; end }
def r2(f) = (z = +"y"; f.call(z); [z, nil].each { |e| yield e }; z.size)
p r2(f) { |t| t << X if t }
s = +"s"; f.call(s); p s.size
s = nil if ARGV.size == 0
p s, s.nil?, "#{s}", (s || "d")
begin; s << "!"; rescue NoMethodError => e; p e.message; end
begin; s.upcase; rescue NoMethodError => e; p e.message; end
r(f) { |t| begin; t.upcase; rescue NoMethodError => e; p e.message; end }
