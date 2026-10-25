# A boxed receiver of a String transform with a boxed String argument:
# a receiver that is not a String raises NoMethodError before the
# argument's conversion can raise TypeError, as CRuby asks first.
def pad(x, w, f) = x.ljust(w, f)
def swap(x, a, b) = x.tr(a, b)
pad("ab", 4, "*") if ARGV.size > 5
swap("ab", "a", "b") if ARGV.size > 5
[[5, 4, 6], ["ab", 4, :s]].each do |x, w, f|
  begin
    p pad(x, w, f)
  rescue NoMethodError, TypeError => e
    p [e.class, e.message]
  end
  begin
    p swap(x, f, "z")
  rescue NoMethodError, TypeError => e
    p [e.class, e.message]
  end
end
