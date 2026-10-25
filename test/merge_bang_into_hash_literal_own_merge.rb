# A program that gives Hash its own merge keeps merge! into a Hash literal
# as written: merge! is not its merge.
class Hash
  def merge(o) = (puts "own merge"; self)
end

p({ "x" => 0 }.merge!({ "a" => 1 }))
