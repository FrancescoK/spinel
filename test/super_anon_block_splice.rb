class Base
  def each_twice
    yield 1
    yield 2
  end
end
class Anon < Base
  def each_twice(&) = super(&)
end
Anon.new.each_twice { |x| p x * 10 }
