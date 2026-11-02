# included: include inside a Struct.new block
module M
  def self.included(b) = puts("inc #{b.superclass}")
end
P = Struct.new(:a) do
  include M
end
puts P.new(1).a
