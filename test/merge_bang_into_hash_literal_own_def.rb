# A Hash#merge! of the program's own, defined with def in a reopened Hash,
# is kept for a Hash literal receiver.
class Hash
  def merge!(o) = (puts "own merge!"; self)
end

p({}.merge!({ a: 1 }))
