# spinel: rbs-seed-check
# A Hash#each value handed to a writer whose RBS signature leaves the value
# `untyped`, and which stores it where a later append reaches it, is refused
# as it is without the signature: the C did not build (#8235).
class UntypedAppendWriter
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

writer = true ? UntypedAppendWriter.new : Hash.new("")
source = { "name" => +"Ada" }
source.each { |key, value| writer[key] = value }
puts source["name"]
