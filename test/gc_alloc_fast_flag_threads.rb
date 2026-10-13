# Threads allocating at once: every allocation that falls back to the
# full form of sp_gc_alloc recomputes the flag that lets the next one take
# the lean front, while the other workers read it. Under
# scripts/tsan-run.sh with SPINEL_WORKERS=2..8 the flag's plain store and
# loads were reported as data races (sp_gc_alloc against sp_gc_alloc_full);
# they are atomic now. Plain `make test` keeps the program honest (the
# sizes are deterministic); the TSan gate is where the race shows.
ts = (1..4).map do |i|
  Thread.new do
    h = {}
    3000.times { |j| h["k#{j % 50}"] = [j, "v#{j}", j.to_s * 3] }
    h.size + h["k7"][1].size * i
  end
end
p ts.map(&:value)
