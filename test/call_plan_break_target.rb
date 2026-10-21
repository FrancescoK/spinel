# A block's break changes the call's answer, not its user-method targets.
class First
  def each
    yield 1
    yield 2
  end
end
class Second
  def each
    yield 3
    yield 4
  end
end
[First.new, Second.new].each do |object|
  p(object.each { |value| break value + 1 })
end
