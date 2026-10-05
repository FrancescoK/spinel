# Float#clamp with a Range on a NaN receiver raises ArgumentError naming the
# begin (the end of a beginless range), as CRuby does, where it answered
# NaN; ordinary receivers clamp as before.
n = Float::NAN
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
t { n.clamp(1..2) }
t { n.clamp(..2) }
t { n.clamp(1..) }
t { n.clamp(1.0..2.0) }
t { n.clamp(..2.5) }
t { n.clamp(1..2.5) }
t { 1.5.clamp(1..2) }
t { 2.5.clamp(1.0..2.0) }
t { 0.5.clamp(..2.5) }
t { Float::INFINITY.clamp(1..2) }
