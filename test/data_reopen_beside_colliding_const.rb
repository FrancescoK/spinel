# A Data or Struct constant reopened as a class in its own module, while
# another module has a constant of the same leaf name. The constants were
# qualified apart (S__C64, M__C64) but the reopening body was not, so it
# became a separate class under the bare leaf: its class method's `new`
# built nothing, and a call on it was refused.
module M
  Profile = Data.define(:name)
  C64 = Profile.new(name: "c64")
  Pair = 2
end

module S
  C64 = Data.define(:ram)

  class C64
    def self.of(ram) = new(ram:)
    def kb = ram * 64
  end

  Pair = Struct.new(:a, :b)

  class Pair
    def self.both(v) = new(v, v)
    def sum = a + b
  end
end

x = S::C64.of(3)
p x.ram
p x.kb
p x.class
p S::Pair.both(4).sum
p M::C64.name
p M::Pair
