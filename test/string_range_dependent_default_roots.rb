# spinel: gc-stress
# spinel: share
# A dependent default binds earlier arguments before the later arguments
# and defaults run. Both ends of each String Range copy stay live there.
def churn
  GC.start
  junk = []
  64.times { |k| junk << ["j#{k}", "k#{k}", "l#{k}"]; junk << "zz#{k}" }
  junk.size
end

def mark(s) = (churn; s)
def tag(i) = "a#{i}"
def ends(r, x, copy = r) = [copy.begin, copy.end, r.begin, r.end, x]
def collected_default(r, x = churn, copy = r) = [copy.begin, copy.end, r.begin, r.end]
def keyword_copy(r, x, copy: r) = [copy.begin, copy.end, x]

class Pair
  def ends(r, x, copy = r) = [copy.begin, copy.end, r.begin, r.end, x]
end

module Ends
  def self.ends(r, x, copy = r) = [copy.begin, copy.end, r.begin, r.end, x]
end

2.times do |i|
  p ends(("a#{i}".."zz"), mark("d#{i}"))
  p ends(("aa".."z#{i}"), mark("e#{i}"))
  p ends((tag(i).."z#{i}"), mark("f#{i}"))
  p collected_default(("a#{i}".."z#{i}"))
  p keyword_copy(("a#{i}".."z#{i}"), mark("k#{i}"))
  p Pair.new.ends(("a#{i}".."z#{i}"), mark("p#{i}"))
  p Ends.ends(("a#{i}".."z#{i}"), mark("m#{i}"))
end
