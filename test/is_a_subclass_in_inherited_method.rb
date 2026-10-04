class Animal
  def describe
    if is_a?(Dog)
      "a dog"
    else
      "not a dog"
    end
  end
end

class Dog < Animal
end

puts Dog.new.describe
