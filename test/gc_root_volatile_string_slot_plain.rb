# A String local a rescue can write is a volatile slot, and is rooted as a
# String all the same. Here in a plain run: the block allocates enough for
# collections to fall while the local is the only holder of its buffer.
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
  v = "none"
  i = 0
  while i < n
    begin
      v = fresh(i)[0].to_s
      s = v if i == 0
      yield i
      Integer("5")
    rescue
    end
    i += 1
  end
  fill = (1..2000).map do |k|
    t = String.new("OVERWRITE-#{k % 10}")
    t << "-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    t
  end
  s + "|" + fill.size.to_s
end

def run
  seen = 0
  r = each_built(3) do |x|
    junk = []
    200_000.times { |k| junk << "junk-#{k}-#{x}" }
    seen += junk.size
  end
  [r, seen]
end
p run
