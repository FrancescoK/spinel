# An alias keeps the body in effect where it appears: a subclass that
# defines the old name again (REXML's Document#add under Parent's
# alias push) does not take the alias, which still runs the class's own
# body, with its super, __method__, block and ivars. It was refused
# (settle_mixin_aliases), and with it every rexml program.
class Base
  def add(x) = "Base#add #{x}"
end
class Parent < Base
  def initialize = @n = 0
  def add(x)
    @n += 1
    "Parent#add(#{@n}) #{x} / #{super} / #{__method__}"
  end
  alias push add
  def each_twice(v) = (yield v; yield v)
  alias twice each_twice
  def <=>(o) = 1
  alias_method :cmp_without, :<=>
end
class Doc < Parent
  def add(x) = "Doc#add #{x}"
  def <=>(o) = super(o) * 10
  def each_twice(v) = yield(v * 100)
end
d = Doc.new
p d.push(2), d.push(3)
d.twice(5) { |x| p x }
p d.cmp_without(d), d <=> d
p Parent.new.push(1)
class Parent
  def add(x) = "Parent#add v2 #{x}"
end
p Parent.new.push(9), Parent.new.add(9)
