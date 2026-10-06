# A builtin called on a local that is nil because no write ran (`a = [1.5]
# if k > 0`) raises NoMethodError, as CRuby does and #7578 made it. Under
# --no-line-map, which the test harness compiles with, the parser stamped no
# positions, and cplan_nil took every unset local for a temp a rewrite made:
# no nil test, and the builtin read the NULL pointer (a segfault).
def show(tag)
  r = yield
  puts "#{tag} #{r.inspect}"
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def arr(k)
  a = [1.5, 2.5] if k > 0
  a.size
end

def str(k)
  s = +"ab" if k > 0
  s.upcase
end

def hash(k)
  h = { a: 1 } if k > 0
  h.keys
end

def splat(*args) = args.size

def through_splat(k)
  xs = [1, 2] if k > 0
  splat(*xs)
end

show("array nil") { arr(0) }
show("array") { arr(1) }
show("string nil") { str(0) }
show("string") { str(1) }
show("hash nil") { hash(0) }
show("hash") { hash(1) }
show("splat nil") { through_splat(0) }
show("splat") { through_splat(1) }
