class Animal
  def describe
    if instance_of?(Animal)
      "a plain animal"
    else
      "some kind of animal"
    end
  end
end

class Dog < Animal
end

puts Dog.new.describe
