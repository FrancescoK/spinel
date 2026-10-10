# String#between? with a String bound that is nil at run time raises CRuby's
# comparison error, where it compared as the empty String. Both bounds are
# evaluated before the compares, which stop at the first false.
def nb(i) = i > 0 ? "a" : nil

def log(x)
  puts "eval #{x.inspect}"
  x
end

def try
  p yield
rescue ArgumentError => e
  p e.message
end

lo = nb(0)
hi = nb(0)
try { "12".between?(lo, "z") }
try { "12".between?("0", hi) }
try { "12".between?("z", hi) }
try { "12".between?(log("0"), log(hi)) }
p "12".between?("3", log("4"))
p "12".between?(log("0"), log("2"))
p log("12").between?(log("0"), log("2"))
p log("12").between?(log("3"), log(nil))
s = nb(1)
p "b".between?(s, "c"), "b".between?("0", s)
x = nb(0)
y = 5
x = y if y > 9
try { "12".between?(x, "z") }
