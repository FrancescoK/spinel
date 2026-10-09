# A Hash#each that stores its String values into another Hash, in a program
# whose own class has a []= that appends to its argument (#8144): the
# store on a Hash cannot reach that []=, so the block's value stays a plain
# String -- it was made a String handle, which the Hash#each binder could
# not fill, and the C did not build. The boxed index write still reaches
# the class's []=, whose parameter it rebinds.
class HashFactory
  def self.build
    {"field" => "Ada"}
  end
end

class RequestLike
  def copy
    target = HashFactory.build
    source = {"field" => "Ada"}
    source.each do |key, value|
      target[key] = value
    end
    target["field"]
  end
end

class OtherContainer
  attr_reader :value

  def initialize
    @value = ""
  end

  def [](key) = nil

  def []=(key, value)
    value << "!"
    @value = value
  end
end

other = OtherContainer.new
other["field"] = +"Grace"
puts "#{RequestLike.new.copy}:#{other.value}"
boxed = [OtherContainer.new, 1].first
boxed["k"] ||= +"Lin"
p boxed.value
