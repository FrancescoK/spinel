# spinel: gc-minor
# Fresh user arms need a handle when the result is kept, but not when a
# builtin only reads it or the caller discards it. A kept result of p still
# carries its identity, and a borrowed return retains its original handle.
class TransientStringReturn
  def initialize
    @text = +"held"
  end
  def upcase = +"user"
  def delete(part) = "user:#{part}"
  def to_s = @text
end

source = +"source"
source_alias = source
source << "!"
[source, TransientStringReturn.new].each do |value|
  p value.upcase
  p(value.upcase)
  p value.upcase.length
  value.upcase
  p value.delete("o")
  value.delete("o")
  kept = value.upcase
  other = kept
  other << "!"
  p kept
  printed = p(value.upcase)
  alias_printed = printed
  alias_printed << "?"
  p printed
end
wrapper = [TransientStringReturn.new, 1][0]
borrowed = wrapper.to_s
alias_borrowed = borrowed
alias_borrowed << "+"
p [borrowed, wrapper.to_s]
p source_alias
