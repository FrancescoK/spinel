# spinel: int64
# An Integer argument slot (String#[], #byteslice, Symbol#[], MatchData#offset
# and friends, Random.new, Array#[], String#*) converts a Rational or a Complex
# through #to_int, as it does a Float: a Rational truncates toward zero, and a
# Complex answers its real part only when its imaginary part is an exact zero.
# An empty [] or {}, or an Array.new, whose element type nothing settles is
# still an Array or a Hash there: CRuby's TypeError, not a pointer in the slot.

def t
  p yield
rescue => e
  p [e.class, e.message.sub(/#<Object:0x\h+>/, "obj")]
end

md = /(f)(o)/.match("fo")

t { "abc"[1r] }
t { "abc"[Rational(-5, 2)] }
t { "abc"[Complex(1)] }
t { "abc"[Complex(1.9, 0)] }
t { "abc"[Complex(1, 2)] }
t { "abc"[Complex(1, 0.0)] }
t { "abc"[Complex(Float::NAN)] }
t { "abc"[1r, Complex(2)] }
t { "abc".byteslice(Rational(5, 2)) }
t { :sym[1r] }
t { :sym.slice(Complex(2)) }
t { md.offset(1r) }
t { md.byteoffset(Complex(2)) }
t { md.begin(Rational(5, 2)) }
t { md.end(Complex(1, 1)) }
t { md[1r] }
t { md.values_at(Complex(2), 1r) }
t { Random.new(Rational(20, 2)).seed }
t { Random.new(Complex(20)).seed }
t { Random.new(Complex(20, 2)).seed }
t { [1, 2, 3][1r] }
t { [1, 2, 3].first(Complex(2)) }
t { "ab" * Rational(5, 2) }
t { Integer(Rational(2**60 + 1, 1)) }
t { Integer(Complex(1, 0.0)) }
t { Complex(3, 0.0).to_i }
t { Complex(3, 4).to_int }

# a boxed one converts the same way
t { k = [Complex(1), "x"][0]; "abc"[k] }
t { k = [Complex(1, 1), "x"][0]; "abc"[k] }

# a boxed MatchData key that is no index is CRuby's TypeError, not group 0
t { md[Object.new] }
t { k = [nil, 1][0]; md[k] }
t { k = [Object.new, "x"][0]; md.values_at(k) }
t { k = [1.9, "x"][0]; md[k] }

t { "abc"[[]] }
t { "abc"[Array.new] }
t { "abc"[{}] }
t { "abc".slice([], 1) }
t { "abc".byteslice({}) }
t { :sym[Array.new] }
t { :sym[[]] }
t { md.offset([]) }
t { md.byteoffset(Array.new) }
t { md.begin({}) }
t { md.end([]) }
t { md[[]] }
t { Random.new({}).seed }
t { [1, 2][Array.new] }
t { [1, 2][{}] }
t { "ab" * [] }
t { "abc".include?([]) }
t { "abc".start_with?(Array.new) }
