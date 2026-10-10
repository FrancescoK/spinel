# The `[gc]` line reports what the last string retune put into the trigger for
# the object old generation (`old obj in str trigger`). A sweep that reclaims
# under a quarter of the string heap puts none in -- it doubles the budget as
# it stands -- so the reading after one has to be zero, not the figure the last
# productive sweep left there.
#
# This program does both in turn. First the shape gc_str_budget_objects.rb
# has: records kept in one Array, every String thrown away, so the sweeps are
# productive and the budget carries the share. Then it keeps every String it
# makes, one a turn with no temporary beside it and each past the size the
# slab takes (2 KB), so a sweep finds the whole young list still live, reclaims
# nothing, and the budget doubles on its own.
#
# The gc-str-budget-test leg reads two arms of the same binary. The default has
# to collect less than half as often as SPINEL_GC_STR_BUDGET=str, which is the
# share at work in the first half; and its last `[gc]` line has to read zero,
# which is the second half taking it back out. It fails with the share never
# carried and with the reading left where the first half put it.
#
# Single-threaded on purpose, as the two siblings are.
class Rec
  attr_reader :id, :qty
  def initialize(id, qty)
    @id = id
    @qty = qty
  end
end

recs = []
i = 0
while i < 150000
  line = "#{i},name-#{i % 1000},#{i * 7}"
  parts = line.split(",")
  recs << Rec.new(parts[0].to_i, parts[2].to_i)
  i += 1
end
kept = []
k = 0
while k < 8000
  kept << ("ab" * 1500)
  k += 1
end
total = 0
recs.each { |r| total = (total + r.qty - r.id) % 1000003 }
bytes = 0
kept.each { |s| bytes += s.size }
puts recs.size
puts total
puts kept.size
puts bytes
