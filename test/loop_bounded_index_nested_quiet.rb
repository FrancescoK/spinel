# spinel: gc-stress
# A while that another loop of its function encloses, proved on its own by
# its `i < a.length` test (loop_bounded_index_nested.rb), leaves its
# safepoint and finalizer polls to the enclosing loop's back-edge when its
# body stores no element: it ends within one pass over an array nothing in it
# can grow. One whose body stores an element keeps its polls ahead of its
# test, since the store can grow the array it counts to (two names can denote
# one). Threads run such loops while the main thread allocates, so the
# collections it starts stop them at the enclosing loops' polls.

# a row-wise histogram: the nested loop polls at the enclosing loop's
# back-edge only
def quiet_hist(rows, fl, n, nf)
  h = Array.new(nf * 4, 0)
  qj = 0
  while qj < n
    ro = qj * nf
    qe = 0
    while qe < fl.length
      k = fl[qe]
      h[k * 4 + rows[ro + k]] += 1
      qe += 1
    end
    qj += 1
  end
  h
end
p quiet_hist([0, 1, 2, 3, 1, 1, 2, 0, 3, 3, 0, 2], [0, 2], 4, 3)

# the nested loop stores into an array of its bound's kind: it keeps its polls
def store_rows(a, b, n)
  sj = 0
  while sj < n
    se = 0
    while se < a.length
      b[se] = a[se] * sj
      se += 1
    end
    sj += 1
  end
  b
end
p store_rows([1, 2, 3], [0, 0, 0], 3)

# ... and still ends when the store grows the very array it counts to
def store_grows(a, n)
  gj = 0
  while gj < n
    ge = 0
    while ge < a.length
      a[a.length] = ge if a.length < 6
      ge += 1
    end
    gj += 1
  end
  a
end
p store_grows([1, 2], 2)

# threads running nested loops over shared arrays while the main thread
# allocates: every collection waits for them at an enclosing loop's poll
def spin(a, rounds)
  s = 0
  pj = 0
  while pj < rounds
    pe = 0
    while pe < a.length
      s += a[pe]
      pe += 1
    end
    pj += 1
  end
  s
end
data = Array.new(2_000, 1)
workers = Array.new(4) { |w| Thread.new { spin(data, 300 + w) } }
junk = 0
3_000.times { |i| junk += [i, i + 1, i.to_s].size }
p workers.map(&:value)
p junk
