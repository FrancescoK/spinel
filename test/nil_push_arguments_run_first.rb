# CRuby evaluates every argument of a call before it finds the receiver is
# nil, so `nil_array.push(1, tick(2))` runs `tick` and then raises
# NoMethodError (#9347). The pushes were made one argument at a time, and the
# first raised before the later arguments ran. The Arrays below are filled by
# `setup`, which the nil calls never reach.
$log = []
$n = 0
def tick(n)
  $log << n
  n
end

def raises(label)
  $log.clear
  $n = 0
  yield
  puts "#{label}: answered #{$log.inspect} n=#{$n}"
rescue NoMethodError => e
  puts "#{label}: #{e.message} after #{$log.inspect} n=#{$n}"
end

# a mixed Array
class PA
  def setup = (@r = [1, "a"])
  def push_two = @r.push(tick(1), tick(2))
  def push_three = @r.push(tick(1), "x", tick(3))
  def append_two = @r.append(tick(1), tick(2))
  def shl = (@r << tick(1))
  def shl_chain = (@r << tick(1) << tick(2))
  def push_stmt
    @r.push(tick(1), tick(2))
    nil
  end
  def append_stmt
    @r.append(tick(1), "x", tick(3))
    nil
  end
  def push_late_stmt
    @r.push(1, tick(2))
    nil
  end
  def push_assign_stmt
    @r.push(1, $n += 1)
    nil
  end
  def append_assign_stmt
    @r.append("x", $n += 1, $n += 1)
    nil
  end
  def append_late_stmt
    @r.append("x", 2, tick(3))
    nil
  end
  def shl_stmt
    @r << tick(1)
    nil
  end
  def shl_chain_stmt
    @r << tick(1) << tick(2)
    nil
  end
  def push_val = (x = @r.push(tick(1), tick(2)); x.size)
  def push_call = @r.push(tick(1), tick(2)).size
  def unshift_two = @r.unshift(tick(1), tick(2))
  def prepend_two = @r.prepend(tick(1), tick(2))
  def insert_two = @r.insert(1, tick(1), tick(2))
  def contents = @r.inspect
end
%i[push_two push_three append_two shl shl_chain push_stmt push_late_stmt push_assign_stmt append_assign_stmt append_stmt append_late_stmt shl_stmt shl_chain_stmt push_val push_call unshift_two prepend_two insert_two].each do |m|
  raises("PA #{m}") { PA.new.public_send(m) }
end
pa = PA.new; pa.setup
$log.clear
pa.push_two
pa.push_three
pa.append_two
pa.shl
pa.shl_chain
pa.push_stmt
pa.push_late_stmt
pa.push_assign_stmt
pa.append_assign_stmt
pa.append_stmt
pa.append_late_stmt
pa.shl_stmt
pa.shl_chain_stmt
p pa.push_val
p pa.push_call
pa.unshift_two
pa.prepend_two
pa.insert_two
p pa.contents
p $log

# typed Arrays: unshift and prepend
class IA
  def setup = (@r = [1, 2])
  def unshift_two = @r.unshift(tick(1), tick(2))
  def prepend_two = @r.prepend(tick(1), tick(2))
  def contents = @r.inspect
end
class FA
  def setup = (@r = [1.5])
  def unshift_two = @r.unshift(tick(1).to_f, tick(2).to_f)
  def prepend_two = @r.prepend(tick(1).to_f, tick(2).to_f)
  def contents = @r.inspect
end
class SA
  def setup = (@r = ["a"])
  def unshift_two = @r.unshift(tick(1).to_s, tick(2).to_s)
  def prepend_two = @r.prepend(tick(1).to_s, tick(2).to_s)
  def contents = @r.inspect
end
%i[unshift_two prepend_two].each do |m|
  raises("IA #{m}") { IA.new.public_send(m) }
  raises("FA #{m}") { FA.new.public_send(m) }
  raises("SA #{m}") { SA.new.public_send(m) }
end
[IA, FA, SA].each do |k|
  o = k.new; o.setup
  o.unshift_two; o.prepend_two
  p o.contents
end

# an Array of objects
class Item
  def initialize(n) = (@n = n)
  attr_reader :n
end
def item(n)
  $log << n
  Item.new(n)
end
class OA
  def setup = (@r = [Item.new(0)])
  def push_two = @r.push(item(1), item(2))
  def append_two = @r.append(item(1), item(2))
  def shl = (@r << item(1))
  def push_stmt
    @r.push(item(1), item(2))
    nil
  end
  def push_late_stmt
    @r.push(Item.new(9), item(2))
    nil
  end
  def push_assign_stmt
    @r.push(Item.new(9), Item.new($n += 1))
    nil
  end
  def ns = @r.map(&:n)
end
%i[push_two append_two shl push_stmt push_late_stmt push_assign_stmt].each do |m|
  raises("OA #{m}") { OA.new.public_send(m) }
end
oa = OA.new; oa.setup
oa.push_two; oa.append_two; oa.shl; oa.push_stmt; oa.push_late_stmt; oa.push_assign_stmt
p oa.ns
