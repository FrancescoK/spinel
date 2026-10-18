# A method whose value is a call on a constant defined nowhere answers
# nothing (its C is a void function) and raises NameError when it runs.
# Interpolated into a String, the call runs there: unreached, nothing
# happens; reached, the NameError comes out of the interpolation.
class Diagnostic
  def initialize(loc)
    @loc = loc
  end

  def message
    Missing.compile(@loc)
  end

  def render
    ["#{@loc}: #{message}"]
  end
end

d = Diagnostic.new(ARGV.size > 5 ? 1 : "a")
p d.render if ARGV.size > 5
puts "not reached: ok"
begin
  p d.render
rescue NameError => e
  p e.class
end
puts "done"
