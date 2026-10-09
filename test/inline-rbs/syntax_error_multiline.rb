# spinel: not-cruby -- a malformed continued signature fails as a whole
class Greeter
  #: (Integer,
  #   String) -> -> String
  def greet(n, s)
    s * n
  end
end

puts Greeter.new.greet(2, "a")
