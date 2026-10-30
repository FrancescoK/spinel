# A Hash parameter is the caller's hash, which may hold values of other
# kinds before the method stores its own: its reads are not typed as the
# class the method stores (#4846's one-class typing), whatever they read.

class Box
  def initialize(s)
    @s = s
  end
  def to_s
    @s
  end
end

# the read before the store
def fill(env)
  n = env["n"]
  env["content"] = Box.new("page")
  n
end
env = {}
env["n"] = 7
p fill(env)
p env["content"].to_s

# the read after the store
def fill_after(env)
  env["content"] = Box.new("page")
  env["n"]
end
env = {}
env["n"] = 7
p fill_after(env)

# two reads
def fill_two(env)
  a = env["a"]
  env["content"] = Box.new("page")
  b = env["b"]
  [a, b]
end
env = {}
env["a"] = 1
env["b"] = 2
p fill_two(env)

# the Integer read used arithmetically
def fill_add(env)
  n = env["n"]
  env["content"] = Box.new("page")
  n + 1
end
env = {}
env["n"] = 7
p fill_add(env)

# a String-keyed Integer-valued Hash from a literal
def fill_lit(env)
  n = env["n"]
  env["content"] = Box.new("page")
  n
end
p fill_lit({"n" => 7})

# the same with a Symbol key
def fill_sym(env)
  n = env[:n]
  env[:content] = Box.new("page")
  n
end
env = {}
env[:n] = 7
p fill_sym(env)
p fill_sym({n: 8})

# storing a String instead
def fill_str(env)
  n = env["n"]
  env["content"] = "page"
  n
end
env = {}
env["n"] = 7
p fill_str(env)
p env["content"]

# a local hash the method builds keeps reading its one class
def local_box
  h = {}
  h["a"] = Box.new("local")
  h["a"].to_s
end
p local_box
