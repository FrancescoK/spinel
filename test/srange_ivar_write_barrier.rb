# A String Range stored into an ivar of an object that is already old is
# recorded by the write barrier: the Range's endpoint Strings, new and held
# by nothing else, were freed by a minor collection that did not walk the
# holder, and read back as freed bytes.
# spinel: gc-stress
class Holder
  def initialize = @r = ("a".."b")
  def set(i) = (@r = ("a#{i}".."z#{i}"))
  def r = @r
end
h = Holder.new
junk = (1..20_000).map { |i| "j#{i}" }
5.times do |i|
  h.set(i)
  junk = (1..2_000).map { |k| "k#{k}" }
  p h.r
end
