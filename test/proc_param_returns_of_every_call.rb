# A proc parameter answers what any caller's proc returns. Each call used to
# overwrite the slot with its own proc's type, so the binding flipped round
# after round, inference never settled, and the calls answered nil.
def run(pr) = pr.call(5)
p run(proc { |x| x * 2 })
p run(proc { |x| "s#{x}" })
p run(proc { |x| })
def keep(pr) = pr
keep(proc { |id| id })
keep(proc { })
p keep(proc { |v| v + 1 }).call(1)
