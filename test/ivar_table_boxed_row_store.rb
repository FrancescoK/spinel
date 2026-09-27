# A boxed array stored as a row of an ivar table: `@banks[0] = pattern`, where
# `pattern` hands back a row read out of the boxed `@patterns`, still narrowed
# @banks to a table of int arrays. The boxed row was then taken as a bare
# sp_IntArray * and read back as garbage ([0, 2, 0, 0, 0, 0, 0, 0]) or crashed.
# A table that is stored a boxed row now stays boxed.
class Store
  def initialize
    @banks = [[]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = pattern
  end
  def pattern
    pattern = @patterns[0]
    pattern << 1
    pattern << 2
    pattern
  end
end
p Store.new.bank

class Push
  def initialize
    @banks = [[]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = pattern
  end
  def pattern
    pattern = @patterns[0]
    pattern.push(1)
    pattern.push(2)
    pattern
  end
end
p Push.new.bank

class Concat
  def initialize
    @banks = [[]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = pattern
  end
  def pattern
    pattern = @patterns[0]
    pattern.concat([1, 2])
    pattern
  end
end
p Concat.new.bank

class Alias
  def initialize
    @banks = [[]]
    @patterns = [[]]
  end
  def bank
    b = pattern
    @banks[0] = b
  end
  def pattern
    pattern = @patterns[0]
    pattern << 1
    pattern << 2
    pattern
  end
end
p Alias.new.bank

class Floats
  def initialize
    @banks = [[]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = pattern
  end
  def pattern
    pattern = @patterns[0]
    pattern << 1.5
    pattern << 2.5
    pattern
  end
end
p Floats.new.bank

class ReadBack
  def initialize
    @banks = [[]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = pattern
    nil
  end
  def first
    @banks[0][0]
  end
  def row
    @banks[0]
  end
  def pattern
    pattern = @patterns[0]
    pattern << 1
    pattern << 2
    pattern
  end
end
r = ReadBack.new
r.bank
p r.first
p r.row
r.row << 3
p r.row

class Shared
  def initialize
    @banks = [[]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = pattern
  end
  def patterns
    @patterns[0] << 9
    @banks[0]
  end
  def pattern
    pattern = @patterns[0]
    pattern << 1
    pattern
  end
end
s = Shared.new
p s.bank
p s.patterns

class IntRows
  def initialize
    @rows = [[]]
  end
  def fill
    @rows[0] = [4, 5]
    @rows << [6]
    @rows[1][0]
  end
end
p IntRows.new.fill
