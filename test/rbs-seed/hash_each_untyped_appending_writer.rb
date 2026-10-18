# A Hash#each value handed to a writer whose RBS signature leaves the value
# `untyped`, and which stores it where a later append reaches it: the
# shared String is that value, as CRuby's is (the copying build refused it,
# #8235; its C had not built).
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
