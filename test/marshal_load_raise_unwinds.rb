# A Marshal.load that raises (an unknown class, a record it cannot read)
# leaves no trace of its parse behind: the reader it published for the
# collector stayed on the active chain past the raise, and the next
# collection walked the parse's dead frame and crashed. The raise reaches
# the program's handler as itself, and later loads and allocations work.
def deep(n, data) = n == 0 ? Marshal.load(data) : deep(n - 1, data)

bad = ["\x04\bo:\bZzz\x00".b, "\x04\b[\x07i\x06o:\bZzz\x00".b, "\x04\b".b + "\xfe".b]
bad.each_with_index do |data, i|
  begin
    deep(10 + i, data)
  rescue ArgumentError, TypeError => e
    p e.class
  end
  junk = []
  200.times { |j| junk << "x#{j}" * 3 }
  p junk.size
end
p Marshal.load(Marshal.dump([1, "two", {three: 3}]))
begin
  begin
    Marshal.load(bad[0])
  rescue ArgumentError => e
    raise e
  end
rescue => e2
  p e2.equal?(e), e2.class
end
