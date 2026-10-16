# An empty container handed to a parameter whose default is an empty container
# is the argument, in any spelling: `Array.new` and `Hash.new` (bare, or in
# parentheses) were evaluated ahead of the call and replaced by a nil box, so
# the parameter was nil; `({})` and `([])` into a parameter other call sites
# type did not compile. The defaults, the positional and keyword parameters
# and initialize take the same spellings. Each callee stores into the
# container it is handed, so a nil, or the wrong kind, shows.
#
# A bare `Array.new` that nothing narrows is the empty Array `[]` is: handed
# to a parameter another call site gives a number, a String or a Hash it
# widens the parameter (a C error, or 0 where the Array was), and as the
# receiver of `freeze`, `dup`, `to_a`, `itself` or `compact`, or the value of
# a conditional, it is an Array (it was nil). The same for `([])`.
module EmptyArgDefault
  def self.arr(a, b = Array.new)
    b << a
    b
  end
  def self.arr_lit(a, b = [])
    b << a
    b
  end
  def self.arr_kw(a, b: Array.new)
    b << a
    b
  end
  def self.hsh(a, b = Hash.new)
    b[:k] = a
    b
  end
  def self.hsh_lit(a, b = {})
    b[:k] = a
    b
  end
  def self.hsh_kw(a, b: {})
    b[:k] = a
    b
  end
  def self.two(a, b = Array.new, c = Hash.new)
    b << a
    c[:k] = a
    [b, c]
  end
end
class EmptyArgDefaultNew
  def initialize(a, b = Array.new, c: Hash.new)
    @r = [b << a, c.merge!(k: a)]
  end
  attr_reader :r
end
p EmptyArgDefault.arr(1, Array.new)
p EmptyArgDefault.arr_lit(2, Array.new)
p EmptyArgDefault.arr_kw(3, b: Array.new)
p EmptyArgDefault.arr(1, (Array.new))
p EmptyArgDefault.arr_lit(2, (Array.new))
p EmptyArgDefault.arr_kw(3, b: (Array.new))
p EmptyArgDefault.arr(1, [])
p EmptyArgDefault.arr_lit(2, [])
p EmptyArgDefault.arr_kw(3, b: [])
p EmptyArgDefault.arr(1, ([]))
p EmptyArgDefault.arr_lit(2, ([]))
p EmptyArgDefault.arr_kw(3, b: ([]))
p EmptyArgDefault.arr(4)
p EmptyArgDefault.arr_kw(5)
p EmptyArgDefault.hsh(1, Hash.new)
p EmptyArgDefault.hsh_lit(2, Hash.new)
p EmptyArgDefault.hsh_kw(3, b: Hash.new)
p EmptyArgDefault.hsh(1, (Hash.new))
p EmptyArgDefault.hsh_lit(2, (Hash.new))
p EmptyArgDefault.hsh_kw(3, b: (Hash.new))
p EmptyArgDefault.hsh(1, {})
p EmptyArgDefault.hsh_lit(2, {})
p EmptyArgDefault.hsh_kw(3, b: {})
p EmptyArgDefault.hsh(1, ({}))
p EmptyArgDefault.hsh_lit(2, ({}))
p EmptyArgDefault.hsh_kw(3, b: ({}))
p EmptyArgDefault.hsh(4)
p EmptyArgDefault.hsh_kw(5)
p EmptyArgDefault.two(6, Array.new, Hash.new)
p EmptyArgDefault.two(7, (Array.new), ({}))
p EmptyArgDefault.two(8)
p EmptyArgDefaultNew.new(1, Array.new, c: Hash.new).r
p EmptyArgDefaultNew.new(2, ([]), c: ({})).r
p EmptyArgDefaultNew.new(3).r

module EmptyArgWiden
  def self.num(b = Array.new)
    p b
  end
  def self.str(b = Array.new)
    p b
  end
  def self.two(x, y = Array.new)
    p [x, y]
  end
  def self.one(x, y = Array.new)
    p [x, y]
  end
  def self.hsh(x, y = Array.new)
    p [x, y]
  end
  def self.paren_arr(x)
    p x
  end
  def self.paren_hsh(x)
    p x
  end
  def self.paren_new(x)
    p x
  end
end
EmptyArgWiden.num(5)
EmptyArgWiden.num(Array.new)
EmptyArgWiden.str("s")
EmptyArgWiden.str(Array.new)
EmptyArgWiden.two(8, Array.new)
EmptyArgWiden.two(Array.new, [1])
EmptyArgWiden.one(8)
EmptyArgWiden.one(Array.new)
EmptyArgWiden.hsh({a: 1})
EmptyArgWiden.hsh(Array.new)
EmptyArgWiden.paren_arr(8)
EmptyArgWiden.paren_arr(([]))
EmptyArgWiden.paren_hsh([1])
EmptyArgWiden.paren_hsh(({}))
EmptyArgWiden.paren_new(8)
EmptyArgWiden.paren_new((Array.new))
p Array.new.freeze
p Array.new.dup
p Array.new.to_a
p Array.new.itself
p Array.new.compact
p Array.new.frozen?
flag = ARGV.size == 0
p((Array.new if flag))
p((Hash.new if flag))
p((([]) if flag))
p((({}) if flag))
p(flag ? ([]) : nil)
p(flag ? ({}) : nil)
p(flag ? nil : ([]))
p(flag ? Array.new : nil)
