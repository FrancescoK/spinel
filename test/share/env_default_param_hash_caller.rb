# A parameter defaulting to ENV that a caller hands a Hash of its own: the
# Strings the Hash holds are the caller's, shared with the name that made
# them, and the method changes them in place. Only the default is ENV's,
# whose Strings are new per read.
def bang(env = ENV)
  v = env["k"]
  v << "!"
  nil
end

def upper(env = ENV)
  env.each_pair { |_k, v| v.upcase! }
  nil
end

def each_bang(env = ENV)
  env.values.each { |v| v << "?" }
  env.each_value { |v| v << "." }
  nil
end

a = +"abc"
bang({"k" => a})
p a

b = +"abc"
upper({"k" => b})
p b

c = +"abc"
each_bang({"k" => c})
p c
