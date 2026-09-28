# A value pushed through a boxed parameter into an array literal argument
def f(o) = o.push("Z")
p f([1])
p f(%w[a])

def u(o) = o.unshift(:s)
p u([1, 2])
p u([2.5])

def ins(o) = o.insert(1, "q")
p ins([1, 2])
p ins([:a])

def set(o)
  o[1] = "x"
  o
end
p set([1, 2])
p set(%w[a b])

def app(o) = o << 1.5
p app(([1]))
p app(%w[z])

# a typed parameter the push widens, handed a new array a builtin answers
def w(o) = o.push("Z")
p w(Array.new(2, 0))
p w([3, 4].select(&:odd?))
p w(([5]))

def h(x) = x["k"] = :v
p h(({"a" => 1}))
