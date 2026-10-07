# An unknown origin or a cycle makes the entire receiver query unbounded.
# These stores do not run, and must not widen the known Hash beside them.
h = {a: 1}
b = [h, $other][ARGV.size]
b[0] = 5 if ARGV.size == 99
p h

j = {b: 2}
x = [j, 1][ARGV.size]
x = x if ARGV.size == 99
x.store(0, 5) if ARGV.size == 99
p j

# Every ivar write form must be counted before accepting a bound. The
# conditional, operator and multiple writes keep these queries unbounded.
@multi = {c: 3}
@multi, other = [{d: 4}, nil] if ARGV.size == 98
bm = [@multi, 1][ARGV.size]
bm[0] = 5 if ARGV.size == 99
p @multi

@either = {e: 5}
@either ||= {f: 6} if ARGV.size == 98
bo = [@either, 1][ARGV.size]
bo[0] = 5 if ARGV.size == 99
p @either

@both = {g: 7}
@both &&= {h: 8} if ARGV.size == 98
ba = [@both, 1][ARGV.size]
ba[0] = 5 if ARGV.size == 99
p @both

@op = [{i: 9}, 1][ARGV.size]
@op += 1 if ARGV.size == 98
bp = [@op, 1][ARGV.size]
bp[0] = 5 if ARGV.size == 99
p @op
