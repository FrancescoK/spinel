# A route from a String a Hash holds to a block parameter in a method the
# program never names: the value never gets there, so the route is not refused.
def parse_query(s)
  h = {}
  s.split("&").each { |pair| h[pair] = +"" }
  h
end

def grow(v) = v << "!"

class Req
  # never called
  def parse_body(s)
    parse_query(s).each { |k, v| grow(v) }
  end
end

p parse_query("a&b")
p grow(+"x")
