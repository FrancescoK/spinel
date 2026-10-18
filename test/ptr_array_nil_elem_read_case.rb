# An Array of objects that holds a nil (a store past its end left a gap)
# and reaches a local, a call's value or a method's value through a case/when.
# The nil fact followed the Array through an `if` and not through a case/when, so
# a call on one of its elements ran with a NULL self and faulted where
# CRuby raises NoMethodError for nil.
class K
  def initialize(v); @v = v; end
  def v; @v; end
end

def gap(x) = (x[3] = K.new(2))
def gapped = (x = [K.new(1)]; gap(x); x)
def plain = [K.new(5)]

def pick(n)
  case n
  when 0 then gapped
  else plain
  end
end

def show(label)
  p yield
rescue NoMethodError
  puts "#{label}: nil element"
end

n = ARGV.size
b = case n
when 0 then gapped
else plain
end
show("local") { b.map { |q| q.v } }
show("method") { pick(n).map { |q| q.v } }
show("each") {
  t = 0
  pick(n).each { |q| t += q.v }
  t
}
show("other arm") { pick(n + 1).map { |q| q.v } }
