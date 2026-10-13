# Threads allocating through many collections, so one concurrent sweep
# follows another. A sweeper thread woken for a sweep the others had
# already finished used to count itself in late and walk the task array
# while the collector wrote the next sweep's tasks into it. Under
# scripts/tsan-run.sh with SPINEL_WORKERS=4 and SPINEL_GC_STRESS=1 that was
# reported as a data race (sp_cs_run_tasks against sp_sched_conc_start);
# a thread now joins only a sweep with a task left unclaimed. Plain
# `make test` keeps the program honest (the totals are deterministic); the
# TSan gate is where the race shows.
ts = (1..4).map do |i|
  Thread.new do
    kept = []
    total = 0
    4000.times do |j|
      a = [j, "s#{j}", j.to_s * (j % 5 + 1)]
      kept << a if j % 40 == 0
      total += a[2].size
    end
    total + kept.size * i
  end
end
p ts.map(&:value)
