# `class << self; ...; self; end` answers the singleton class. Used as the
# value of an `if`, `case` or begin arm, a rescue modifier or `||`, it was
# left a statement and answered nil; only a method's, block's or lambda's
# last statement and a parenthesized one were taken for a use. The same for
# `class << Bar` on a class the program defines.

class Foo
  def self.by_if(k)
    if k == 0
      class << self; self; end
    else
      nil
    end
  end

  def self.by_case(k)
    case k
    when 0 then class << self; self; end
    end
  end

  def self.by_begin
    begin
      class << self; self; end
    end
  end

  def self.by_rescue
    begin
      raise "x"
    rescue
      class << self; self; end
    end
  end

  def self.by_or(x)
    x || class << self; self; end
  end

  def self.by_parens = (class << self; self; end)

  # the value is thrown away: still a statement
  def self.dropped(k)
    if k == 0
      class << self
        def hi = "hi"
        self
      end
    end
    1
  end
end

class Bar; end

# a constant naming a class of the program
def bar_meta(k)
  if k == 0
    class << Bar; self; end
  end
end

k = ARGV.size
p bar_meta(k)
x = k == 0 ? (class << Bar; self; end) : nil
p x
p Foo.by_if(k)
p Foo.by_case(k)
p Foo.by_begin
p Foo.by_rescue
p Foo.by_or(nil)
p Foo.by_parens
p Foo.dropped(k)
p Foo.hi
