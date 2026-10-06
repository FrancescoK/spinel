# Layer-1 extension fixture (ext-design.md): a plain-Ruby kernel whose
# entries are exported by --ext-entry and driven by a C host (host.c).
module ExtKernel
  def self.triple(n)
    n * 3
  end

  def self.shout(s)
    s.upcase + "!"
  end

  def self.total(arr)
    t = 0
    i = 0
    while i < arr.length
      t += arr[i]
      i += 1
    end
    t
  end

  # Two array parameters: the host converts the second while the first is
  # already built, so the first must stay rooted across that conversion.
  def self.pair_sum(a, b)
    raise ArgumentError, "needs a non-empty first array" if a.empty?
    t = 0
    a.each { |s| t += s.length }
    b.each { |s| t += s.length }
    t
  end

  def self.must_pos(n)
    raise ArgumentError, "needs a positive number" if n <= 0
    n
  end

  def self.pause_total(arr, delay)
    sleep(delay)
    total(arr)
  end
end

TOPLEVEL_NOTE = "toplevel ran"

if __FILE__ == $0
  p ExtKernel.triple(5)
  p ExtKernel.shout("hey")
  p ExtKernel.total([1, 2, 3])
  p ExtKernel.must_pos(9)
  p ExtKernel.pair_sum(["ab", "c"], ["def"])
  p ExtKernel.pause_total([1, 2, 3], 0.001)
end
