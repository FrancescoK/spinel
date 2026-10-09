# spinel: share
# spinel: gc-minor
# A break in an overridden builtin singleton call supplies the call result.
class File
  def self.open(value)
    yield value
    99
  end
end
p File.open(7) { |value| break value + 1 }
p File.open(7) { |value| value + 1 }
p File.open(7) { |value| break value + 1 if false }
p File.open(7) { |value| break value + 1 if value > 5 }
p File.open(7) { break }
p File.open(7) { break +"result" }
p File.open(7) { |value| [value].each { break 12 }; break value }
p File.open(7) { |value| break File.open(value) { |inner| break inner + 2 } }
