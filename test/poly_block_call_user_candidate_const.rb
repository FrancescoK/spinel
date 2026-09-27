# A block call on a boxed receiver whose name a constructed user class also
# defines is typed the same during inference as after it, so a constant
# holding its value gets the slot the method returns. The shape of the
# badline C64 emulator's CPU write masks, beside a user `map(r, w)`.
class Pager
  def map(read_pages, write_pages)
    read_pages + write_pages
  end
end

def mask(plan)
  plan.map { |step| step == :b }
end

A = mask([:a, :b])
p A
p mask({ k: [:b] }[:k])
p Pager.new.map(1, 2)

WRITE_STEPS = %i[w].freeze
PLANS = { r: %i[f r], w: %i[f w w] }.freeze

Micro = Struct.new(:plan, :writes) do
  def self.write_mask(plan)
    plan.map { |step| WRITE_STEPS.include?(step) }.freeze
  end

  def self.build(name)
    plan = PLANS[name]
    new(plan, write_mask(plan))
  end
end

FETCH_WRITES = Micro.write_mask(%i[f])

class CPU
  def initialize
    @writes = FETCH_WRITES
    @last = Micro.write_mask(%i[w f])
  end

  def run(name)
    @writes = Micro.build(name).writes
    @writes.length
  end

  attr_reader :writes, :last
end

cpu = CPU.new
p cpu.writes
p cpu.last
p cpu.run(:w)
p cpu.writes
p FETCH_WRITES.frozen?

# The candidate's `map` yields: the call still dispatches to it.
class Bag
  def initialize(items)
    @items = items
  end

  def map
    @items.map { |i| yield(i) + 100 }
  end
end

def doubled(list)
  list.map { |v| v * 2 }
end

DOUBLED = doubled([1, 2])
p DOUBLED
p doubled({ k: [3, 4] }[:k])
p doubled(Bag.new([5]))
