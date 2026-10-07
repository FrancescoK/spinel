# A Symbol is no index of a String, nor of a Symbol, whose [] is its
# String's. Through a boxed receiver the read answered nil.

def pick(n) = n > 0 ? {a: 1} : +"abc"

def report
  yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

s = pick(0)
report { p s[:a] }
report { s[:a] += "x" }

y = [:sym, {a: 1}][0]
report { p y[:a] }

# a String that is shared
t = +"shared"
u = [t, {a: 1}][0]
t << "!"
report { p u[:a] }

# the index boxed too
k = [:a, 0][0]
report { p s[k] }

# an Integer, a String, a Range and a Regexp answer as before, and so does a Hash
p s[0]
p s["b"]
p s["z"]
p s[0..1]
p s[/c/]
p y[0]
p u[-1]
p pick(1)[:a]
