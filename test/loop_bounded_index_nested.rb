# The `i = 0; while i < a.length ... a[i] ... i += 1; end` proof
# (loop_bounded_index_read.rb) for loops nested in another loop. A nested while
# runs in the enclosing loop's header cache (a while's or an Integer block
# loop's), and is proved on its own: its reads need no bounds test. An
# enclosing loop with a loop in its body is not proved in a program that polls
# (this one starts a thread): the nested loop polls between the enclosing
# loop's test and its reads after the nested loop, and the thread or finalizer
# a poll runs can shrink the array, so those reads keep their test. The answers
# are the same either way.
Thread.new { 0 }.join

# a nested loop proved on its own, in a method over its parameters (a row-wise
# histogram: every row updates every listed feature's slot)
def hist(rows, fl, n, nf)
  h = Array.new(nf * 4, 0)
  j = 0
  while j < n
    ro = j * nf
    e = 0
    while e < fl.length
      k = fl[e]
      h[k * 4 + rows[ro + k]] += 1
      e += 1
    end
    j += 1
  end
  h
end
p hist([0, 1, 2, 3, 1, 1, 2, 0, 3, 3, 0, 2], [0, 2], 4, 3)

# an enclosing loop that reads a[o] after a nested while
def after_while(a, n)
  s = 0
  o = 0
  while o < a.length
    k = 0
    while k < n
      s += k
      k += 1
    end
    s += a[o]
    o += 1
  end
  s
end
p after_while([5, 6, 7], 3)

# ... and after a nested Integer block loop
def after_times(a, n)
  s = 0
  ob = 0
  while ob < a.length
    n.times { |q| s += q }
    s += a[ob]
    ob += 1
  end
  s
end
p after_times([5, 6, 7], 3)

# a while nested in an Integer block loop, which caches the headers too
def in_times(a, n)
  s = 0
  n.times do |q|
    wi = 0
    while wi < a.length
      s += a[wi]
      wi += 1
    end
  end
  s
end
p in_times([5, 6, 7], 3)

# three deep: only the innermost loop holds no loop of its own
def three(a, b, c)
  s = 0
  oi = 0
  while oi < a.length
    mi = 0
    while mi < b.length
      ie = 0
      while ie < c.length
        s += c[ie]
        ie += 1
      end
      s += b[mi]
      mi += 1
    end
    s += a[oi]
    oi += 1
  end
  s
end
p three([1, 2], [10, 20, 30], [100, 200])
