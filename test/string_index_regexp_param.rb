# String#index / #rindex with a Regexp held in a parameter or an ivar,
# not written inline at the call.
def ix(s, re) = s.index(re)
def ix2(s, re, i) = s.index(re, i)
def rx(s, re) = s.rindex(re)
def rx2(s, re, i) = s.rindex(re, i)
p ix("aébab", /b/)
p ix("aaa", /b/)
p ix2("aébab", /b/, 3)
p rx("aébab", /b/)
p rx2("aébab", /b/, 3)
p rx("aaa", /b/)

class Finder
  def initialize(re) = @re = re
  def first(s) = s.index(@re)
  def last(s) = s.rindex(@re)
end
f = Finder.new(/o/)
p f.first("foo boo")
p f.last("foo boo")
