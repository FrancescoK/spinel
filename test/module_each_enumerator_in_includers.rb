# A module's yielding #each, mixed into classes (rackup's Stream::Reader):
# each including class enumerates its own instances, and the module, which
# has no instances, has nothing of its own to compile.
module Reader
  def read_partial = @parts.shift
  def each
    while chunk = read_partial
      yield chunk
    end
  end
end
class Input
  include Reader
  def initialize(parts) = @parts = parts
end
class Body
  include Reader
  def initialize(parts) = @parts = parts
end
Input.new(%w[a b]).each { |c| p c }
p Body.new(%w[x y]).to_enum(:each).to_a
