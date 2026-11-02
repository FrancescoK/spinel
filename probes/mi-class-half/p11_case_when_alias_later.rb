class Cat; end
class Dog; end
def kind(x)
  case x
  when Pet then :pet
  else :other
  end
end
Pet = Dog
p kind(Dog.new), kind(Cat.new)
