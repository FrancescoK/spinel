# spinel: gc-stress
# A C stack that runs out is CRuby's SystemStackError, and a program that
# rescues it goes on running. Spinel died on SIGSEGV instead: the fault was
# read as an ordinary segfault, and nothing named the stack. The fault handler
# recognizes the thread's own guard now and raises through the exception slots
# -- it runs on the alternate signal stack, so the raise touches none of the
# memory the overflow just ran off the end of, and it allocates nothing (the
# allocator is not safe to re-enter from a signal).
# The same under SPINEL_GC_STRESS=2 or SPINEL_GC_VERIFY=1: the verifier's
# fault report, installed first, kept the handler from being installed, and
# the report ran on the stack that had run out and died of SIGILL.
def deep(n) = n < 0 ? 0 : 1 + deep(n + 1)
def a(n) = n < 0 ? 0 : 1 + b(n + 1)
def b(n) = n < 0 ? 0 : 1 + a(n + 1)

begin
  deep(0)
rescue SystemStackError => e
  puts "rescued: #{e.class}"
end

# the stack is usable again afterwards, and a second overflow is caught too
3.times do |i|
  begin
    deep(0)
  rescue SystemStackError
    puts "again #{i}"
  end
end

# mutual recursion fills the stack the same way
begin
  a(0)
rescue SystemStackError
  puts "mutual: rescued"
end

# ordinary work still runs, and the collector is unharmed by the unwind
acc = []
1000.times { |i| acc << "s#{i}" }
p acc.length
p [1, 2, 3].map { |x| x * 2 }

# SystemStackError is not a StandardError, so a bare rescue does not take it
def guarded
  deep(0)
rescue => e
  "wrong: #{e.class}"
end
begin
  guarded
rescue SystemStackError
  puts "bare rescue passed it through"
end

# The guard must not fire on a recursion that is merely deep. Machine-generated
# code recurses far further than hand-written code does -- a compiled function
# body calls its callee directly, ten thousand frames down -- and a guard that
# mistook that for an overflow would refuse programs that are fine.
def countdown(n) = n <= 0 ? 0 : 1 + countdown(n - 1)
p countdown(10_000)

def fac(n) = n <= 1 ? 1 : n * fac(n - 1)
p fac(12)

# ...and a deep recursion that is rescued still leaves the stack usable for the
# next deep one, rather than each rescue costing a little of it
2.times do
  begin
    deep(0)
  rescue SystemStackError
    p countdown(10_000)
  end
end
