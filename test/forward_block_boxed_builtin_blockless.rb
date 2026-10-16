# `t.each_pair(&b)` / `t.map(&b)` on a value that is a builtin collection
# or a program object, from a method whose caller passed no block: the
# builtin answers its blockless form (an Enumerator), and a block given
# runs. The boxed dispatch dropped the Hash's arm (NoMethodError), and the
# map form yielded to no block (LocalJumpError).

class Obj
  def each_pair = :mine
  def map = :mapped
end

def pairs(t, &b) = t.each_pair(&b)
def mapped(t, &b) = t.map(&b)

p pairs({ a: 1 }).to_a
p pairs(Obj.new)
pairs({ a: 1 }) { |k, v| p [k, v] }

p mapped([1, 2]).to_a
p mapped({ b: 2 }).to_a
p mapped(Obj.new)
p mapped([1, 2]) { |x| x * 10 }
