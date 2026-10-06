# Range#overlap? and Range#bsearch on a String Range answer about the Range,
# not its members: overlap? compares the String ends (CRuby's range_overlap),
# and bsearch raises TypeError, since only a numeric Range searches. Both
# went through the member Array, which has no overlap? (NoMethodError, or
# RangeError for an endless range) and whose bsearch searched.

def err
  yield
rescue => e
  [e.class, e.message]
end

sr = ("a".."e")
sx = ("a"..."e")
se = ("a"..)
sb = (.."e")
p [sr.overlap?(sr), sr.overlap?("c".."z"), sr.overlap?("e".."z"), sx.overlap?("e".."z"), sr.overlap?("f".."z")]
p [se.overlap?(se), se.overlap?(sb), sb.overlap?(sb), sr.overlap?(se), sr.overlap?(("x"..))]
p [sr.overlap?("c".."a"), ("c".."a").overlap?(sr), sx.overlap?("a"..."a")]
p [sr.overlap?(100..200), sb.overlap?(..5), se.overlap?(1..)]
p err { sr.overlap?("c") }
p err { sr.bsearch { |x| x >= "c" } }
p err { se.bsearch { |x| x >= "c" } }
p err { sb.bsearch { |x| x >= "c" } }
boxed = [sr, 1]
p [boxed[0].overlap?("d".."f"), boxed[0].overlap?(sr), boxed[0].overlap?(1..2)]
p err { boxed[0].bsearch { |x| x >= "c" } }
