# An alias of an attr_reader reads the ivar, under any name -- `to_s`
# included, which every object answers otherwise. activesupport's
# Multibyte::Chars has `alias to_s wrapped_string`. A call of the alias
# was typed as the reader but emitted as Object's own to_s, and the C did
# not compile.
class Chars
  attr_reader :wrapped_string
  alias to_s wrapped_string
  alias to_str wrapped_string
  def initialize(s) = @wrapped_string = s
  def bare = to_s
  def via_self = self.to_s
  def via_param(o) = o.to_s
end
c = Chars.new(:ef)
p c.to_s
p c.bare
p c.via_self
p c.via_param(c)
p c.to_str
p Chars.new("gh").to_s.upcase
