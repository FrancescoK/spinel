# spinel: int64
# coerce on a Rational read out of a mixed Array: an Integer becomes a
# Rational, a Float makes both Floats, and anything else is TypeError.
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
r = [3r / 4, :a][0]
t { r.coerce(1) }
t { r.coerce(1.5) }
t { r.coerce(2r) }
t { r.coerce(2**70) }
t { r.coerce("a") }
t { r.coerce(nil) }
a, b = r.coerce(2)
t { a + b }
t { [12, :a][0].coerce(2.5) }
t { [12, :a][0].coerce(3) }
t { [1.5, :a][0].coerce(2) }
t { r.coerce(true) }
