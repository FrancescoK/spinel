# A Hash built in one method, returned, and handed to a method that stores
# values of another type into it is built as the Hash those stores need,
# followed back through the method's value and the locals on the way.
class Box
  def initialize(s)
    @s = s
  end
  def to_s
    @s
  end
end

# through a local
def new_env
  env = {}
  env["n"] = 7
  env
end
def fill(env)
  env["content"] = Box.new("page")
  env.size
end
env = new_env
p fill(env)
p env["content"].to_s
p env["n"]

# the call itself as the argument
def new_env2
  env = {}
  env["n"] = 7
  env
end
def fill2(env)
  env["content"] = Box.new("page")
  env.size
end
p fill2(new_env2)

# the caller stores a String first
def new_env3
  env = {}
  env["n"] = 7
  env
end
def fill3(env)
  env["content"] = Box.new("page")
  env.size
end
env3 = new_env3
env3["title"] = "x"
p fill3(env3)
p env3["content"].to_s
p env3["title"]

# two methods back
def new_env4
  env = {}
  env["n"] = 7
  env
end
def outer_env = new_env4
def fill4(env)
  env["content"] = Box.new("page")
  env.size
end
e4 = outer_env
p fill4(e4)
p e4["content"].to_s
p fill4(outer_env)

# a String stored instead of a Box
def new_env5
  env = {}
  env["n"] = 7
  env
end
def fill5(env)
  env["content"] = "page"
  env.size
end
e5 = new_env5
p fill5(e5)
p e5["content"]

# the literal at the call, and a Hash whose values are mixed already
def titled_env
  env = new_env4
  env["title"] = "x"
  env
end
def fill6(env)
  env["content"] = Box.new("page")
  env.size
end
p fill6(titled_env)
e6 = {}
e6["n"] = 7
p fill6(e6)
p e6["content"].to_s
