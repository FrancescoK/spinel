# A String local a rescue can write is a volatile slot, and is rooted as a
# String all the same: the buffer it names stays alive when nothing else
# holds it. Run under SPINEL_GC_STRESS=2 by gc-stress-test.
# spinel: gc-stress
APPEND = ->(x) { x << "-appended-0123456789-abcdefghij" }

def fresh(i)
  b = String.new("payload-#{i}")
  APPEND.call(b)
  [b, i]
end

# a yielding method, spliced into its caller: its local is rooted where the
# caller's are
def each_built(n)
  s = "start"
  i = 0
  while i < n
    begin
      s = fresh(i)[0].to_s
      APPEND.call(String.new("other"))
      yield i
      Integer("5")
    rescue
    end
    i += 1
  end
  APPEND.call(String.new("last"))
  junk = (1..50).map { |k| "junk-#{k}-" * 8 }
  s + junk.size.to_s
end

def run
  seen = 0
  r = each_built(3) { |x| seen += x }
  [r, seen]
end
p run
