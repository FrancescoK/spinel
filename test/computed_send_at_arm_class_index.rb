# A computed send whose receiver may hold a Class value and whose name may
# be :at: the at arm checks the receiver and converts the index into temps
# declared inside its statement, and the index read behind the check is a
# class-receiver [] dispatch (the program calls Reg[] and Tbl[] on their
# classes). What that dispatch hoists -- the receiver's hold, the index's
# spill -- must sit inside the statement too, after those temps; in the
# statement's prelude it read them before their declaration and the C did
# not compile.
class Reg
  def self.[](k)
    "Reg[#{k}]"
  end
end

class Tbl
  def self.[](k)
    "Tbl[#{k}]"
  end
end

class Bag
  def [](k)
    "Bag##{k}"
  end
end

class Stamp
  def self.at(i)
    "Stamp.at(#{i})"
  end
end

class Zone
  def at(i)
    "Zone.at(#{i})"
  end
end

class Scalar
  attr_reader :value
  def initialize(value)
    @value = value
  end

  def calc(op, other)
    Scalar.new(value.public_send(op, other.value))
  end
end

puts Reg[0], Tbl[0], Stamp.at(0), Zone.new.at(0), Bag.new[0]
TABLE = { 0 => 3, 1 => Reg, 2 => Tbl, 3 => Stamp, 4 => Zone.new, 5 => "str" }
ops = [:+, :at, :[]]
6.times do |i|
  ops.each do |op|
    begin
      p Scalar.new(TABLE[i]).calc(op, Scalar.new(1)).value
    rescue NoMethodError, TypeError => e
      puts "#{e.class}: #{e.message[0, 40]}"
    end
  end
end
