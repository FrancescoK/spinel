# A method of a class that is never instantiated is reached by its name only
# (another class's method of that name is called), with argument types from
# callers that never reach it. A refusal inside it stopped the build (#7280).
def stamp(t)
  t.utc.to_i.to_s
end

class NV
  def generate(value, expires_at)   # never called: no NV is ever built
    value + stamp(expires_at)
  end
end

class Other
  def generate(a)                   # the live `generate`
    a
  end
end

# A class whose subclass is built keeps its methods as they are.
class Base
  def generate(a) = "base #{a}"
end
class Kid < Base; end

puts stamp(Time.at(1791069292))
puts Other.new.generate("x")
puts Kid.new.generate("y")
