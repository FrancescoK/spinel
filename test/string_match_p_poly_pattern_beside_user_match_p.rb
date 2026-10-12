# A user class's own match?(pattern) that calls String#match?(pattern) raised
# NoMethodError for the String once another match? call had a boxed receiver:
# that dispatch counted the user method, its pattern widened to a boxed
# Regexp-or-String, and the String receiver's match? with a boxed pattern
# stood down for the program's match?, which no String can reach. A String
# receiver now asks only whether the program reopens String with the name.
class Agent
  def initialize(s)
    @s = s
  end

  def match?(pattern)
    @s.match?(pattern)
  end
end

def probe(r, key)
  r.match?(key)
end

p Agent.new("Chrome").match?(/Chrome/)
p Agent.new("Chrome").match?("Chr")
p probe(/x/, "x")
p probe(Agent.new("y"), "y")
p probe(Agent.new("y"), /z/)
