# Fiber.prepend(M) and Thread.include(M) at the top level are the
# reopening `class Fiber; prepend M; end` (fiber-annotation's shape)
module Tag
  def tag
    "fiber #{resume}"
  end
end

module Name
  def label
    "thread #{value}"
  end
end

Fiber.prepend(Tag)
Thread.include(Name)

puts Fiber.new { 1 }.tag
puts Thread.new { 2 }.label
p Fiber.new { 3 }.respond_to?(:tag)
