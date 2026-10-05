# A String subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: String's methods, reached at run time: the readers, the mutators
# (which change it in place) and the iterators.
# Each probe takes a fresh instance.
class Buf < String
  def initialize(src) = (super("ab"); @src = src)
  def label = "buf"
end

def fresh
  pg = Buf.new("x")
  objs = [pg, [9], {a: 1}, 3]
  objs[0]
end

o = fresh
p o.size
o = fresh
p o.length
o = fresh
p o.empty?
o = fresh
p o.upcase, o.upcase.class
o = fresh
p o.include?("b"), o.include?("z")
o = fresh
p o.index("b")
o = fresh
p o.start_with?("a")
o = fresh
p o[0], o[0, 2]
o = fresh
o << "c"; p o, o.class
o = fresh
o.concat("d"); p o
o = fresh
o.upcase!; p o
o = fresh
o.replace("zz"); p o
o = fresh
p o.chars
o = fresh
o.each_char { |ch| print ch }; puts
o = fresh
p o.reverse
o = fresh
p o.sub("a", "A")
o = fresh
p o.split("")
o = fresh
p o.to_sym
o = fresh
p o.ord
