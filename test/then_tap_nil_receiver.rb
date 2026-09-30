# The block parameter of `then` and `tap` is the receiver, nil included:
# an Integer or Float receiver that can hold nil hands its nil to the
# parameter, whose reads then answer as nil's. Under --int-overflow=promote,
# where every Integer local is boxed, the parameter is unboxed with its nil
# kept, and a boxed nil is an Integer-keyed hash's nil key as the unboxed one
# is.

def t
  yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

x = 1
p x.then { |y| y.nil? }
x = nil
p x.then { |y| y.nil? }
t { p x.then { |y| y + 1 } }
p x.then { |y| [y].compact }
p x.tap { |y| p y }
p x.yield_self { |y| y.to_s }
f = [1.5][ARGV.size + 1]
p f.then { |y| y.nil? }
t { p f.then { |y| y * 2 } }
p f.tap { |y| p [y, y.nil?] }

w = 2
h = {}
h[w] = 1
w = nil
g = {}
g[w] = 1
g[3] = 4
p h, g, g.keys, g.to_a
g.each { |k, v| p [k, k.nil?, v] }
