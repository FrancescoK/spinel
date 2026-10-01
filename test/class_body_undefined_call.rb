# A class body runs top to bottom: a Kernel call that acts (raise, warn,
# printf, pp) runs where it stands, and a call nothing defines is
# NoMethodError there, not a declaration skipped silently
class E
  printf("%d\n", 5)
  pp [1]
end
begin
  class C
    unknown_m "x"
    def hi = "hi"
  end
rescue NoMethodError => e
  puts e.message
end
begin
  class F
    raise ArgumentError, "boom"
  end
rescue ArgumentError => e
  puts e.message
end
p :after
