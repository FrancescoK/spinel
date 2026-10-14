# A Struct whose block adds attr_accessor, built through `k.new(...)` on a
# class value: the constructor takes the members only, not the accessors.

Tok = Struct.new(:type, :text) do
  attr_accessor :prev
end

class Plain
  def initialize(a) = @a = a
end

[Tok, Plain].each { |k| p k.new("x").class }
[Tok].each do |k|
  t = k.new(:lit, "a")
  t.prev = 1
  p [t.type, t.text, t.prev]
  p t.to_a
end
begin
  [Tok].each { |k| k.new(1, 2, 3) }
rescue ArgumentError => e
  p e.message
end
