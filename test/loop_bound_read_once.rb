# Integer#times, #upto and #downto read their bound once
# The count of n.times and the limit of upto/downto sat in the C loop
# condition, so a bound the block writes was read again every round:
# `k.times { k = 1 }` ran once, `(n - 2).times { n -= 1 }` twice, and
# `1.upto(n) { n = 0 }` stepped past its limit and never ended. Ruby
# evaluates the receiver and the limit once, as a Range's each and a for
# loop already did here.

k = 4
c = 0
k.times { k = 1; c += 1 }
p c

n = 5
c = 0
(n - 2).times { n -= 1; c += 1 }
p c

@m = 3
c = 0
@m.times { @m = 0; c += 1 }
p c

def run(k)
  c = 0
  k.times { |i| k = 0 if i == 0; c += 1 }
  c
end
p run(5)

# written in a nested block, with next and break
n = 4
c = 0
n.times { [1].each { n = 100 }; c += 1 }
p c
n = 6
c = 0
n.times { |i| n = 1; next if i.odd?; c += 1; break if i > 3 }
p c

# a generator drawing in the block decides its own count
x = 7
r = []
3.times { (x % 4).times { x = (x * 75 + 74) % 65537; r << x % 10 } }
p r

# upto and downto, an Integer limit and a Float one
n = 6
c = 0
1.upto(n) { n -= 1; c += 1 }
p c
n = 3
c = 0
1.upto(n) { n = 0; c += 1 }
p c
m = -2
c = []
3.downto(m) { |i| m = 2; c << i }
p c
f = -1.3
c = []
-5.upto(f) { |i| f = 9.0; c << i }
p c
g = 2.5
c = []
1.upto(g) { |i| g = 0.0; c << i }
p c
q = 3
1.upto(q) { q.times { q = 0 } }
p q

# the receiver is evaluated before the limit, as Ruby does
n = 2
c = []
(n = 4).upto(n) { |i| c << i }
p c
x = 1
c = []
x.upto(x += 3) { |i| c << i }
p c
def start_low
  @low = 1
  5
end
@low = 9
c = []
start_low.downto(@low) { |i| c << i }
p c

# the enumerator forms were already read once
k = 3
p(k.times.map { k = 0; 1 }.sum)
k = 4
p(k.times.sum { k = 1; 2 })
