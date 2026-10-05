# Flag-only: without the flag (as on master) each route is refused.
# Routes master refuses for a String pass when the rule hands the String
# along as its handle: a Hash's appending default block, a nested multiple
# assignment, Thread and Fiber arguments, a Hash's [key, value] pairs and a
# retained scrub!.
h = Hash.new { |hh, k| hh[k] = +"" }
h[:a] << "x"
h[:a] << "y"
p h
s = +"str"
a, (b, c) = 1, [s, 2]
b << "!"
p s, a, c
t = +"thr"
Thread.new(t) { |x| x << "+" }.join
p t
f = +"fib"
Fiber.new { |x| x << "-" }.resume(f)
p f
pairs = { k: +"v" }.to_a
pairs[0][1] << "1"
p pairs
r = +"ab"
r2 = r.scrub!
r << "c"
p r, r2
