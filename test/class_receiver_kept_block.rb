class DirectBlock
  def self.invoke(callback, value)
    callback ? callback.call(value) : :missing
  end

  def self.run(value, &block)
    invoke(block, value)
  end

  def self.zero(&block)
    invoke(block, 10)
  end

  def literal(value)
    self.class.run(value) { |n| n * 2 }
  end

  def forwarded(value, &block)
    self.class.run(value, &block)
  end

  def absent(value)
    self.class.run(value)
  end

  def zero
    self.class.zero { |n| n - 1 }
  end
end

class NamedBlock
  def self.invoke(callback, value)
    callback.call(value)
  end

  def self.run(&block)
    invoke(block, name)
  end

  def save
    self.class.run { |value| value }
  end
end

class NamedChildBlock < NamedBlock
end

p NamedBlock.new.save
p NamedChildBlock.new.save

class RaisingDefaultBlock
  def self.run(&block)
    @kept = block
    raise(block ? "default with block" : "default without block")
  end

  def save
    self.class.run { 17 }
  end
end

def invoke_default_block(callback)
  callback.call
end

class ReturningBlock < RaisingDefaultBlock
  def self.run(&block)
    invoke_default_block(block)
  end
end

begin
  RaisingDefaultBlock.new.save
rescue RuntimeError => error
  puts error.message
end
p ReturningBlock.new.save

direct = DirectBlock.new
p direct.literal(3)
p direct.forwarded(4) { |n| n + 2 }
p direct.forwarded(5, &nil)
p direct.absent(6)
p direct.zero
p direct.class.run(7) { |n| n + 1 }

def block_receiver
  puts "receiver"
  DirectBlock.new
end
p block_receiver.class.run(8) { |n| n + 1 }

class SwitchedBlock
  def self.invoke(callback, value)
    callback ? callback.call(value) : :missing
  end

  def self.run(value, &block)
    invoke(block, value)
  end

  def literal(value)
    self.class.run(value) { |n| n * 3 }
  end

  def forwarded(value, &block)
    self.class.run(value, &block)
  end

  def absent(value)
    self.class.run(value)
  end
end

class ChildBlock < SwitchedBlock
  def self.run(value, &block)
    invoke(block, value + 1)
  end
end

class RaisingBlock < SwitchedBlock
  def self.run(value, &block)
    @kept = block
    raise "raised #{value}"
  end
end

base = SwitchedBlock.new
child = ChildBlock.new
p base.literal(2)
p child.literal(2)
p base.forwarded(3) { |n| n + 10 }
p child.forwarded(3) { |n| n + 10 }
p base.absent(4)
p child.absent(4)
begin
  RaisingBlock.new.literal(5)
rescue RuntimeError => error
  puts error.message
end
