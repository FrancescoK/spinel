# A class read whose parent is unset raises before a later Array or Hash
# literal operand builds, for builtin calls that take their operands as written.
class Target
  class Child; end
end
def fx(n)
  puts "fx#{n}"
  n
end
module Outer
  def self.push
    xs = []
    xs.push(Outer::HOLDER::Child, [puts('array')])
    p xs.size
  rescue NameError => e
    puts e.message
  end
  def self.hash
    xs = []
    xs.push(Outer::HOLDER::Child, { key: puts('hash') })
    p xs.size
  rescue NameError => e
    puts e.message
  end
  def self.insert
    xs = [0]
    xs.insert(0, Outer::HOLDER::Child, [puts('insert')])
    p xs.size
  rescue NameError => e
    puts e.message
  end
  def self.unshift
    xs = []
    xs.unshift(Outer::HOLDER::Child, [puts('unshift')])
    p xs.size
  rescue NameError => e
    puts e.message
  end
  def self.print
    p(Outer::HOLDER::Child, [puts('print')])
  rescue NameError => e
    puts e.message
  end
  def self.middle
    xs = []
    xs.push(1, Outer::HOLDER::Child, [(puts('middle'); 2)])
    p xs.size
  rescue NameError => e
    puts e.message
  end
  # an operand that is neither a literal nor bound (an interpolated regexp)
  # leaves the class read and the operands in their order
  def self.regexp
    xs = []
    xs.push(Outer::HOLDER::Child, /a#{fx(1)}/)
    p xs.size
  rescue NameError => e
    puts e.message
  end
  def self.regexp_print
    p(Outer::HOLDER::Child, /a#{fx(1)}/)
  rescue NameError => e
    puts e.message
  end
  def self.regexp_after
    xs = []
    xs.push(fx(0), Outer::HOLDER::Child, /a#{fx(1)}/)
    p xs.size
  rescue NameError => e
    puts e.message
  end
end
Outer.push
Outer.hash
Outer.insert
Outer.unshift
Outer.print
Outer.middle
Outer.regexp
Outer.regexp_print
Outer.regexp_after
module Outer
  HOLDER = (puts 'assigned'; Target)
end
Outer.push
Outer.hash
Outer.insert
Outer.unshift
Outer.print
Outer.middle
Outer.regexp
Outer.regexp_print
Outer.regexp_after
