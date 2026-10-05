module Fetcher
end

class Animal
  def describe
    if is_a?(Fetcher)
      "fetches"
    else
      "does not fetch"
    end
  end
end

class Dog < Animal
  include Fetcher
end

puts Dog.new.describe
puts Animal.new.describe
cat = Animal.new
cat.extend(Fetcher)
puts cat.describe
