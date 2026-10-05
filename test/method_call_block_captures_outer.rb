# A block passed to a Method shares both read-only and written outer locals.
def capture_yield = yield

def capture_twice
  yield
  yield
end

def capture_parameter(z)
  x = 1
  method(:capture_yield).call do
    x = 2 if z.nil?
  end
  p x
end
capture_parameter(nil)
capture_parameter(3)

def capture_values
  integer = 7
  float = 1.5
  string = "read"
  array = [2, 3]
  nothing = nil
  wi = 0
  wf = 0.0
  ws = "before"
  wa = [0]
  wn = 1
  m = method(:capture_twice)
  m.call do
    p integer, float, string, array, nothing
    wi += integer
    wf += float
    ws = string
    wa = array
    wn = nothing
  end
  p wi, wf, ws, wa, wn
end
capture_values

def capture_aliases(parameter)
  m = method(:capture_yield)
  m.() { p parameter }
  m.[] { p parameter }
  m.=== { p parameter }
  method(:capture_yield).() { p parameter }
  method(:capture_yield).[] { p parameter }
  method(:capture_yield).=== { p parameter }
end
capture_aliases("aliases")

def capture_nested(parameter)
  count = 0
  method(:capture_twice).call do
    2.times do |i|
      method(:capture_yield).call do
        p parameter, i
        count += 1
      end
    end
  end
  p count
end
capture_nested(9)
