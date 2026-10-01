# A runtime-name send carries its block to the method it reaches: a
# forwarded `&blk`, and a block written at the send. The lowering built one
# arm per candidate name and left the block on the send itself, so the
# yielding method raised LocalJumpError.
class Person
  def initialize(n) = @n = n
  def name = @n
  def each_letter = @n.each_char { |ch| yield ch }
  def fwd(m, &blk) = send(m, &blk)
  def fwd_pub(m, &blk) = public_send(m, &blk)
  def pick(m) = send(m) { |ch| print ch, "." }
end
pe = Person.new("Ann")
m = [:each_letter, :name].first
pe.send(m) { |ch| print ch, "-" }
puts
pe.public_send(m) { |ch| print ch, "+" }
puts
pe.fwd(m) { |ch| print ch, "*" }
puts
pe.fwd_pub(m) { |ch| print ch, "/" }
puts
pe.pick(m)
puts
p pe.fwd(:name) { |ch| print ch }
p pe.send(m.to_s) { |ch| print ch }
puts
