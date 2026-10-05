class Animal
  def describe
    if is_a?(Comparable)
      "compares"
    else
      "does not compare"
    end
  end
end

class Dog < Animal
  include Comparable

  def <=>(other)
    0
  end
end

puts Dog.new.describe
puts Animal.new.describe
