# defined?((e)) asks of e: parentheses around one statement are looked
# through, two statements are an "expression" and none are "nil". Every
# parenthesized form answered "expression".
class W
  attr_accessor :n
  def initialize; @n = 1; end
end
a = 1
@b = 2
w = W.new
p defined?((a)), defined?((a += 1)), defined?(((a = 2))), defined?((@b)), defined?((@b += 1))
p defined?((puts)), defined?((1 + 1)), defined?((zz)), defined?((w.n)), defined?((w.zz))
p defined?((w.n += 1)), defined?((a; @b)), defined?((zz; a)), defined?(())
p [a, @b, w.n]
