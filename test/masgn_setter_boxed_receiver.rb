# A setter target in a multiple assignment whose receiver is boxed (a
# parameter some other call widened) dispatches on the receiver's class.

class Machine
  attr_accessor :a, :b

  def initialize
    @a = 1
    @b = 2
  end
end

class Panel
  attr_reader :a, :b, :log

  def initialize
    @a = 0
    @b = 0
    @log = []
  end

  def a=(v)
    @log << v
    @a = v * 10
  end

  def b=(v)
    @b = v.to_s
  end
end

class Image
  def restore(machine)
    machine.a, machine.b = [3, 4]
    machine.a + machine.b
  end

  def short(machine)
    machine.a, machine.b = 5
    [machine.a, machine.b]
  end

  def splat(machine, rest)
    machine.a, *machine.b = rest
    [machine.a, machine.b]
  end

  def nested(machine)
    (machine.a, machine.b), x = [6, 7], 8
    [machine.a, machine.b, x]
  end

  def swap(machine)
    machine.a, machine.b = machine.b, machine.a
    [machine.a, machine.b]
  end

  def both(target)
    target.a, target.b = 1, 2
    [target.a, target.b]
  end
end

class Store
  def restore(bytes) = bytes.bytesize
end

module Saved
  def restore_store(bytes) = @store.restore(bytes)
end

class Holder
  include Saved

  def initialize
    @store = Store.new
  end
end

img = Image.new
puts img.restore(Machine.new)
p img.short(Machine.new)
p img.splat(Machine.new, [1, 2, 3])
p img.nested(Machine.new)
p img.swap(Machine.new)
p img.both(Machine.new)
panel = Panel.new
p img.both(panel)
p panel.log
puts Holder.new.restore_store("abc")
begin
  img.both(Store.new)
rescue NoMethodError => e
  puts e.message.split(" for ").first
end
