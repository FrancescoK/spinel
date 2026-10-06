class Animal
  def kind
    case self
    when Dog then "a dog"
    when Animal then "an animal"
    end
  end

  def base_first
    case self
    when Animal then "an animal first"
    when Dog then "a dog first"
    end
  end

  def pet
    case self
    when Dog, Cat then "a pet"
    else "wild"
    end
  end

  def via_param
    classify(self)
  end

  def via_local
    me = self
    case me
    when Dog then "local: a dog"
    when Cat then "local: a cat"
    else "local: an animal"
    end
  end

  def announce
    case self
    when Dog
      puts "statement: a dog"
    when Animal
      puts "statement: an animal"
    end
  end
end

class Dog < Animal
end

class Cat < Animal
end

class Rock
  def kind
    case self
    when Rock then "a rock"
    else "not a rock"
    end
  end
end

def classify(a)
  case a
  when Cat then "param: a cat"
  when Dog then "param: a dog"
  else "param: an animal"
  end
end

[Dog.new, Cat.new, Animal.new].each do |a|
  puts a.kind
  puts a.base_first
  puts a.pet
  puts a.via_param
  puts a.via_local
  a.announce
end

puts Rock.new.kind
