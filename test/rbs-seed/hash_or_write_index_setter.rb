# `(@traps ||= {})[addr] = handler` stores into the hash @traps holds, so it
# types @traps like `@traps[addr] = handler` does. The write was no evidence,
# the empty literal left @traps boxed, and a boxed `[]=` bound its arguments
# to the unrelated SeedOrwMem#[]=: a Proc reached the declared Integer
# parameter of SeedOrwMem#poke and the C did not compile. The same holds
# through a getter whose value is the or-write.
# spinel: rbs-seed-check
class SeedOrwMem
  def initialize
    @cells = Array.new(4, 0)
  end

  def poke(addr, value)
    @cells[addr] = value
  end

  def []=(addr, value)
    poke(addr, value)
  end

  def [](addr) = @cells[addr]
end

class SeedOrwTraps
  def install(addr, &handler)
    (@traps ||= {})[addr] = handler
  end

  def fire(addr) = @traps[addr].call
end

class SeedOrwHooks
  def hooks = (@hooks ||= {})

  def hook(addr, &blk)
    hooks[addr] = blk
  end

  def run(addr) = hooks[addr].call
end

mem = SeedOrwMem.new
mem.poke(1, 7)
traps = SeedOrwTraps.new
traps.install(3) { 42 }
hooks = SeedOrwHooks.new
hooks.hook(2) { "irq" }
p mem[1], traps.fire(3), hooks.run(2)
