# String#clamp with a bound that is not a String: nil, another class, or a
# value known only at run time. The arm read every bound into a String slot,
# so such a call did not build. It is Comparable#clamp over the boxed values
# now: a nil side is open, a class a String does not compare with raises
# CRuby's ArgumentError, and a nil receiver is NoMethodError.

def t(k)
  log = []
  s = +"ab"
  [[nil, nil], [nil, "b"], ["a", nil], [7, 8], [7, "a"], ["a", 7],
   [[1], [2]], [:a, :b], [Rational(1, 2), "a"], ["b", nil], [1.5, nil]].each do |lo, hi|
    begin
      p s.clamp(lo, hi)
    rescue ArgumentError => e
      p e.message
    end
  end
  a = [+"b", :x][k]
  p s.clamp(a, "z")
  p s.clamp("a", [+"aa", 1][k])
  p s.clamp((log << 1; nil), (log << 2; "b"))
  n = k == 0 ? nil : +"x"
  begin
    n.clamp((log << 3; nil), "b")
  rescue NoMethodError => e
    p e.class
  end
  p log
end

t(ARGV.size)
