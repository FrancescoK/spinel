# The non-blocking forms of a boxed Queue: pop/shift/deq(non_block) and
# a SizedQueue's push/enq(obj, non_block). The flag is never an element.
def t(l) = (r = yield; puts "#{l}: #{r.inspect}") rescue puts("#{l}: #{$!.class}: #{$!.message}")
q = Queue.new
sq = SizedQueue.new(1)
b = [q, 1][0]
s = [sq, 1][0]
a = [[1, 2], 1][0]
t("pop(true) empty") { b.pop(true) }
t("shift(true) empty") { b.shift(true) }
t("deq(true) empty") { b.deq(true) }
b << 7
t("pop(true) item") { b.pop(true) }
b << 8
t("pop(false) item") { b.pop(false) }
b << 9
t("deq(false) item") { b.deq(false) }
t("Queue enq(x, true)") { b.enq(1, true) }
t("Queue push(x, true)") { b.push(1, true) }
t("SizedQueue enq(x, true) room") { s.enq(:a, true).class }
t("SizedQueue enq(x, true) full") { s.enq(:b, true) }
t("SizedQueue push(x, true) full") { s.push(:b, true) }
t("SizedQueue size") { s.size }
t("SizedQueue pop(true)") { s.pop(true) }
t("SizedQueue push(x, false)") { s.push(:c, false).class }
t("SizedQueue size after") { s.size }
t("Array pop(true)") { a.pop(true) }
t("Array pop(1)") { a.pop(1) }

# the flag itself held in a boxed slot
yes = [true, 1][0]
no = [false, 1][0]
t("pop(boxed true) empty") { b.pop(yes) }
b << 11
t("pop(boxed true) item") { b.pop(yes) }
b << 12
t("shift(boxed false) item") { b.shift(no) }
t("Queue push(x, boxed true)") { b.push(1, yes) }
t("SizedQueue push(x, boxed true) full") { s.push(:d, yes) }
t("SizedQueue size unchanged") { s.size }
# and a boxed count on a real Array is still a count
n = [1, "x"][0]
t("Array pop(boxed 1)") { [[5, 6, 7], 1][0].pop(n) }
