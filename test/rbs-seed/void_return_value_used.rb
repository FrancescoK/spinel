# spinel: rbs-seed-run
# RBS `void` says a method's value is not meant to be used, not what it is:
# the method still returns its body's value, and a caller may use it
# (activesupport 8.1's signatures declare many methods `-> void`). The
# extractor seeded such a return as nil, which emptied the value a direct
# call answered and gave a dynamic call (public_send) a C void to box.
class VoidRet
  def initialize = @n = 0
  def bump = @n += 3
  def label(s) = "#{s}#{@n}"
end

v = VoidRet.new
p v.bump
p v.public_send(:bump)
p v.label("n=")
