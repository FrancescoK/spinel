# A Regexp matcher's operand converts as CRuby's reg_operand does: a String,
# a Symbol by its name, nil as no match, an object through its #to_str, and
# anything else the TypeError naming its class (=== answers false instead).
class S; def to_str = "xblah"; end
class N; end
class P; def =~(_) = true; end

def t
  yield.inspect
rescue TypeError => e
  "TypeError: #{e.message}"
end

r = /la/
s = S.new
n = N.new
puts t { r =~ s }
puts t { /la/ =~ s }
puts t { r !~ s }
puts t { r.match?(s) }
puts t { r === s }
puts t { r.match(s)&.[](0) }
puts t { r =~ n }
puts t { r =~ 5 }
puts t { r =~ true }
puts t { r =~ :abla }
puts t { /la/.match?(:la) }

box = [s, n, 5, 2.5, true, false, :bla, "la", nil, [1]]
box.each do |v|
  puts "#{v.class}: #{t { r =~ v }} #{t { r !~ v }} #{t { r.match?(v) }} #{t { r === v }} " \
       "#{t { r.match(v)&.[](0) }} #{t { /la/ =~ v }} #{t { /la/.match?(v) }} " \
       "#{t { /la/ === v }} #{t { /la/.match(v)&.to_s }}"
end

case s
when /la/ then puts "when: #{$~[0]}"
else puts "when: miss"
end
case box[0]
when /la/ then puts "when boxed: #{$~[0]}"
else puts "when boxed: miss"
end
re = Regexp.new("bl")
case s
when re then puts "when value: #{$~[0]}"
else puts "when value: miss"
end
case s
in /la/ then puts "in: hit"
else puts "in: miss"
end
case n
when /la/ then puts "N: hit"
else puts "N: miss"
end

# a matcher that is a Regexp, a String turned into one, or an object of its own
def am(m, o)
  m = Regexp.new(Regexp.escape(m)) if String === m
  m =~ o
end
puts t { am("la", s) }
puts t { am(/la/, s) }
puts t { am(/x/, "y") }
puts t { am(P.new, 5) }
puts t { am(/la/, n) }
puts t { am(/la/, 5) }
puts t { am(/la/, true) }
puts t { am(/la/, :bla) }
puts t { am(/la/, nil) }
def mq(m, o) = m.match?(o)
puts t { mq(/la/, s) }
puts t { mq("la", "xla") }

# === sets $~ as =~ does, on a Regexp literal or a Regexp-typed value
class V; def initialize(n) = @n = n; def to_str = "x#{@n}la"; end
r2 = /b(l)/
p(r2 === s, $~ && $~[0], $1)
r3 = Regexp.new("l(a)")
p(r3 === s, $~ && $~[0], $1)
p(r3 === "xla", $~ && $~[0], $1)
p(r3 === nil, $~)
p(r3 === V.new(3), $~ && $~[0])
p(r3 === 5, $~)
def ce(r, o)
  x = (r === o)
  [x, $~ && $~[0]]
end
p ce(/l(a)/, s), ce(Regexp.new("bl"), s), ce(r3, "zla"), ce(r3, :la)
