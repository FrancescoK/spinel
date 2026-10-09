# spinel: share
# spinel: gc-minor
# `recv::X = v` runs its receiver once, before the value, and names a class
# value after that receiver's namespace; a receiver that is no Class or
# Module raises TypeError after the value ran.
module M; end
module Deep; module Inner; end; end

m = M
m::X = Class.new
p M::X
p M::X.name

module N
  self::Y = Class.new
  p N::Y
end

def ns
  puts "ns called"
  M
end
ns::Z = Class.new
p M::Z
p M::Z.name
ns::W = 1
p M::W

def inner = Deep::Inner
inner::Q = Class.new
p Deep::Inner::Q

# the receiver is a local holding one of two namespaces
which = ARGV.empty? ? Deep : M
which::V = Class.new
p which::V.name

# the receiver is evaluated before the value
def recv_first
  puts "receiver"
  M
end
recv_first::Late = (puts "value"; 7)
p M::Late
# ...also when the value builds a prelude of its own
recv_first::Sorted = [3, 1, 2].map { |x| puts "elt #{x}"; x * 2 }.sort.first
p M::Sorted
recv_first::Upper = "abc".then { |s| puts "then"; s.upcase }
p M::Upper
recv_first::Built = begin
  puts "in begin"
  Class.new
end
p M::Built

# receivers of other shapes: a conditional, a class method, an element, a hash value
module Fork; end
class Holder
  def self.space = Deep
  def kind = Fork
end
(ARGV.empty? ? Fork : Deep)::Pick = Class.new
p Fork::Pick
Holder.space::Made = Class.new
p Deep::Made
Holder.new.kind::Five = 5
p Fork::Five
[M][0]::Elem = Class.new
p M::Elem
{ key: Deep }[:key]::Val = Class.new
p Deep::Val

# a class assigned through two namespaces keeps the first name
shared = Class.new
[M, Deep].each { |space| space::Same = shared }
p shared.name

# a receiver that is no Class or Module
[5, nil, "str", [1, 2], :sym].each do |recv|
  begin
    puts "value in play"
    recv::Bad = 1
  rescue TypeError => e
    puts e.message
  end
end
def five
  puts "five called"
  5
end
begin
  five::Bad = (puts "value"; 1)
rescue TypeError => e
  puts e.message
end

# a constant that holds a value or merely holds a module (an alias), and a
# builtin module, is a receiver like any other
NotModule = 5
begin
  NotModule::Held = (puts "value"; 1)
rescue TypeError => e
  puts e.message
end
Alias = M
Alias::ViaAlias = Class.new
p M::ViaAlias.name
Math::Extra = Class.new
p Math::Extra.name

# an anonymous class is a namespace too, and self at the top level is main
anon = Class.new
anon::Nested = Class.new
p anon::Nested.name.sub(/0x\h+/, "XX")
begin
  self::Top = 1
rescue TypeError => e
  puts e.message
end
