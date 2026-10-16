# A class method answering an Integer or nil, called on a class or module
# value only the run time knows: the dispatch held its answer as a plain
# Integer, and the C did not compile (#8985). A sibling class whose method
# never answers nil rides in the same switch.
module M
  def self.upd(x)
    x ? 1 : nil
  end

  def self.rate(x) = x ? 1.5 : nil
end

module N
  def self.upd(x) = x ? 2 : 3
  def self.rate(x) = 0.5
end

def launch(g, x) = g.upd(x)
def speed(g, x) = g.rate(x)

p launch(M, true), launch(M, false), launch(N, false)
p launch(M, false).nil?
p speed(M, true), speed(M, false), speed(N, false)
