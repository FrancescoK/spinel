# spinel: not-cruby -- two signatures for one method are refused
class Greeter
  #: (Integer) -> String
  # @rbs n: Integer
  def greet(n)
    "hi" * n
  end
end

puts Greeter.new.greet(2)
