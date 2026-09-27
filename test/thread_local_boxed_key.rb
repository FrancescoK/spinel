# Thread#[] / #[]= / #key? with a key that is not statically a Symbol: a
# boxed Symbol (out of #keys, an Array, a Hash) is used as is, a String names
# the Symbol it spells, and any other kind is a TypeError, as in CRuby.

# save and restore every local through a Hash keyed by #keys
saved = Thread.current.keys.each_with_object({}) { |k, h| h[k] = Thread.current[k] }
Thread.current[:zz] = 5
saved.each { |k, v| Thread.current[k] = v }
p Thread.current[:zz]                       # 5

key = [:a, "b"].first
Thread.current[key] = 1
p Thread.current[key]                       # 1
p Thread.current[:a]                        # 1

# a String key is the Symbol it spells
p Thread.current["b"]                       # nil
Thread.current["b"] = 2
p Thread.current[:b]                        # 2
p Thread.current.key?("b")                  # true
p Thread.current.key?([:a, "b"].last)       # true
name = +"na"
name << "me"
Thread.current[name] = "x"
p Thread.current[:name]                     # "x"
p (Thread.current["r"] = 7)                 # 7

p Thread.current.keys.sort                  # [:a, :b, :name, :r, :zz]

# storing nil removes the local
Thread.current[:b] = nil
p Thread.current.key?(:b)                   # false
p Thread.current.keys.sort                  # [:a, :name, :r, :zz]

saved = Thread.current.keys.each_with_object({}) { |k, h| h[k] = Thread.current[k] }
Thread.current[:zz] = 6
saved.each { |k, v| Thread.current[k] = v }
p Thread.current[:zz]                       # 5

# any other kind of key is refused
[1, nil, 1.5, [1]].each do |k|
  begin; Thread.current[k]; rescue TypeError => e; p [:get, e.message]; end
  begin; Thread.current[k] = 1; rescue TypeError => e; p [:set, e.message]; end
  begin; Thread.current.key?(k); rescue TypeError => e; p [:key, e.message]; end
end

# another thread's locals, read and listed from outside
t = Thread.new { Thread.current["w"] = 3; Thread.current.keys }
p t.value                                   # [:w]
p t["w"]                                    # 3
p t.keys                                    # [:w]
