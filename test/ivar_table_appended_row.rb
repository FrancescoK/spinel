# A boxed array appended as a row of an ivar table (`@banks << pick(0)`,
# where `pick` hands back a row read out of the boxed `@patterns`) still
# narrowed @banks to a table of int arrays: only `[]=` stores and whole
# writes were vetted. The boxed row was then read back as a bare
# sp_IntArray * and printed garbage ([0, 0, 0, 0, 0, 0, 0, 0]). Appends,
# inserts and concats are rows too, and a table handed out as a value
# (a reader, a local alias) stays boxed.

class Store
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def pick(i) = @patterns[i]
  def grow
    @banks << pick(0)
    @banks[1]
  end
end
p Store.new.grow

class Shift
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def pick(i) = @patterns[i]
  def grow
    @banks.unshift(pick(0))
    @banks[0]
  end
end
p Shift.new.grow

class Push
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def pick(i) = @patterns[i]
  def grow
    @banks.push(pick(0))
    @banks[1]
  end
end
p Push.new.grow

class Ins
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def pick(i) = @patterns[i]
  def grow
    @banks.insert(1, pick(0))
    @banks[1]
  end
end
p Ins.new.grow

class Cat
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def pick(i) = @patterns[i]
  def grow
    @banks.concat([pick(0)])
    @banks[1]
  end
end
p Cat.new.grow

class Flt
  def initialize
    @banks = [[1]]
  end
  def grow
    @banks << [1.5, 2.5]
    @banks[1]
  end
end
p Flt.new.grow

class Rdr
  attr_reader :banks
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def pick(i) = @patterns[i]
  def second = @banks[1]
end
rd = Rdr.new
rd.banks << rd.pick(0)
p rd.second

class Pure
  def initialize
    @banks = [[1]]
  end
  def grow
    @banks << [2, 3]
    @banks[1].sum
  end
end
p Pure.new.grow

class Shim
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def banks = @banks
  def pick(i) = @patterns[i]
  def second = @banks[1]
end
sh = Shim.new
sh.banks << sh.pick(0)
p sh.second

class Alias
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def pick(i) = @patterns[i]
  def grow
    b = @banks
    b << pick(0)
    @banks[1]
  end
end
p Alias.new.grow

class Acc
  attr_accessor :banks
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def pick(i) = @patterns[i]
  def second = @banks[1]
end
ac = Acc.new
ac.banks.push(ac.pick(0))
p ac.second

class Keep
  def initialize
    @banks = [[1, 2]]
  end
  def grow
    @banks << [3, 4]
    @banks.unshift([0])
    @banks[1].sum + @banks[2].sum
  end
end
p Keep.new.grow
