# frozen_string_literal: true
require_relative 'sample'
class CextBox
  attr_accessor :ruby_value
end
box = CextBox.new
box.store(42)
box.ruby_value = 7
p box.get
p box.ruby_value
p CextBox.count(1, 2, 3)
p box.echo('yielded') { |value| value + ' back' }
s = +'ruby'
t = s
box.decorate(s)
p [s, t]
a = [1, 2]
b = a
box.push(a)
p [a, b]
p CextBox::ONE.equal?(CextBox::TWO)
p CextBox::ONE.equal?(box.constant)
p CextBox::ONE.encoding.name
100.times do
  begin
    box.explode
  rescue RuntimeError => e
    raise 'bad exception' unless e.message == 'from C'
  end
end
box.store('alive')
box.collect
p box.get
p box.echo(12) { |value| value + 3 }

class CextChild < CextBox
  def initialize(value)
    self.ruby_value = value
  end
end
child = CextChild.new(27)
child.store(99)
p [child.get, child.ruby_value]
p CextChild.allocate.get
h = {1 => 2}
box.store(h)
h['key'] = 'value'
p box.get

p box.respond_to?(:value)
p box.value
p box.method(:store).arity
p CextBox.count
p box.packed(1, 2, 3, 4)
strings = [+'s']
box.decorate(strings[0])
p strings
nested = [[1, 2]]
box.nested(nested)
p nested
begin
  box.decorate('frozen')
rescue FrozenError
  puts 'frozen'
end

p box.echo(1) { break 73 }
def return_through_c(box)
  box.echo('value') { return 81 }
  0
end
p return_through_c(box)
p box.echo(5) { |n| box.echo(n + 1) { |v| v + 2 } }
f1 = Fiber.new do
  box.echo(10) { |n| Fiber.yield(n); n + 1 }
end
f2 = Fiber.new do
  box.echo(20) { |n| Fiber.yield(n); n + 2 }
end
p [f1.resume, f2.resume, f1.resume, f2.resume]

p CextBox.count(CextBox.new, CextBox.new)
copy = child.dup
p [copy.equal?(child), copy.get, copy.ruby_value]
box.store(child)
copy2 = box.get.dup
p [copy2.equal?(child), copy2.get, copy2.ruby_value]
inner = [3, 4]
outer = []
outer_alias = outer
outer_alias.push(inner)
box.nested(outer)
p inner

p child.store(5).class == CextChild
p child.get

box.number = 24
p box.number
p CextHelpers.from_module
p CextBox::SYM
class CextCustomError
  attr_accessor :detail
end
begin
  box.custom_error
rescue CextCustomError => error
  error.detail = 61
  p [error.message, error.detail]
end
p box.method(:store).parameters
p box.method(:packed).parameters
p box.method(:store).source_location
method = box.method(:store)
method.call(14.5)
p box.get
untouched = [2, 3]
p untouched
p box.method(:store).source_location.nil?

left = CextLeft::Box.new
right = CextRight::Box.new
left.store(17)
right.store(18)
p [left.get, right.get, left.class.name, right.class.name]
parent = CextParent.new
parent.level = 21
data_child = CextDataChild.new
data_child.level = 22
data_child.store(23)
p [parent.level, data_child.level, data_child.get]

source = [1, 2]
p box.push(source.map { |n| n + 1 })
p source
p box.push(source.reverse)
p box.packed
p box.decorate_entry('abc'.chars)
strings_source = [+'a', +'b']
string_alias = strings_source[1]
p box.decorate_entry(strings_source.reverse)
p [strings_source, string_alias]

p box.buffer
captured = nil
p box.push(Array.new(2, 4).tap { |ary| captured = ary })
p captured
begin
  box.push(Array.new(1, 7).freeze)
rescue FrozenError
  puts 'frozen array'
end
