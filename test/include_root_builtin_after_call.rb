# `include ::Enumerable` names the core module, which a later
# `module Enumerable` of the program gives `tag`. The call ahead of the
# include raises NameError in CRuby; Spinel's one chain, the last, would
# answer "enum tag"; refused, as `include Enumerable` is.
class C
  def x = tag
  def each = yield(1)
end
c = C.new
begin
  p c.x
rescue NameError
  puts "NameError"
end
class C
  include ::Enumerable
end
module Enumerable
  def tag = "enum tag"
end
p c.x
