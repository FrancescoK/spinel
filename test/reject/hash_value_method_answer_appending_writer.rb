# A String a Hash a method answers hands, through Hash#each, to a poly []=
# whose user writer stores it where a later append reaches it, is refused as
# one a Hash local or literal holds is: the C did not build (#8278).
class Writer
  def initialize
    @values = {}
  end

  def []=(key, value)
    @values[key] = value
  end

  def mutate
    @values["name"] << "!"
  end
end

module Source
  def self.build
    { "name" => +"Ada" }
  end
end

writer = true ? Writer.new : Hash.new("")
Source.build.each { |key, value| writer[key] = value }
puts "ok"
