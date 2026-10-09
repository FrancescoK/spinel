# spinel: not-cruby -- a malformed inline RBS signature is a compile error
class Greeter
  #: (Integer -> String
  def greet(n)
    "hi" * n
  end
end

puts Greeter.new.greet(2)
