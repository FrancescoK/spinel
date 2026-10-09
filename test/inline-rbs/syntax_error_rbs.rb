# spinel: not-cruby -- a malformed `# @rbs` annotation is a compile error
class Greeter
  # @rbs is how we write types
  def greet(n)
    "hi" * n
  end
end

puts Greeter.new.greet(2)
