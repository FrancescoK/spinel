# A block forwarded with &b into String#gsub / #sub: the block's param is
# bound to each matched substring.
def f(s, x, &b) = s.gsub(x, &b)
p f("abc", "b") { |m| m.upcase }
p f("abcb", "b") { |m| m.upcase + "!" }

def g(s, &b) = s.sub(/b+/, &b)
p g("abbbc") { |m| m.length.to_s }

def h(s, &b) = s.gsub(/[ac]/, &b)
p h("abc") { |m| m * 2 }

def len(s, &b)
  r = s.gsub("a", &b)
  r.length
end
p len("aa") { |m| m * 3 }
