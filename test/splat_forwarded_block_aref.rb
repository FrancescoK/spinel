# `def [](*args, &block) = e.[](*args, &block)` (regexp_parser's
# Subexpression forwarders) beside another forwarder of the kind: the
# forwarded &block is a read every arm of the length dispatch shares, so
# Array#[] takes one index or two, as CRuby does.

class Sub
  def initialize = @e = []
  def e = @e
  def <<(x) = e << x
  def [](*args, &block) = e.[](*args, &block)
  def index(*args, &block) = e.index(*args, &block)
end

s = Sub.new
s << 1
s << 2
p s[0], s[1], s[0, 2], s[5]
