# The decisions a small program with three methods reaches: a root frame and
# a forced inline for each of them, and a frame for the top-level body.
def first_word(s)
  parts = s.split(" ")
  parts[0]
end

def last_word(s)
  parts = s.split(" ")
  parts[parts.length - 1]
end

def grow(s, n)
  s << "!" * n
end

h = {}
k = "a b"
h[k] = first_word(k)
case h[k]
when "a" then puts "first " + last_word(k)
else puts "other"
end
x, y = k, 2
puts x, y
puts h.fetch(k, "none")
n = {}
n[k] = 1
puts n.fetch(k, 0)
$log = +"log"
grow($log, 3)
puts $log
