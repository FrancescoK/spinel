# histogram - count and sum into bins, `counts[b] += 1; sums[b] += v`
#
# The op-assign on an element of a typed array is the inner step of every
# histogram, bucket sort and split search. Measures that it folds the
# element in place rather than reading it and writing it back through two
# bounds checks.

def histogram(bins, vals, nbins, reps)
  total = 0
  sum = 0.0
  r = 0
  while r < reps
    counts = Array.new(nbins, 0)
    sums = Array.new(nbins, 0.0)
    j = 0
    n = bins.length
    while j < n
      b = bins[j]
      counts[b] += 1
      sums[b] += vals[j]
      j += 1
    end
    total += counts[r % nbins]
    sum += sums[r % nbins]
    r += 1
  end
  [total, sum]
end

n = 200_000
bins = Array.new(n) { |i| (i * 7919) % 64 }
vals = Array.new(n) { |i| (i % 13) * 0.25 }
p histogram(bins, vals, 64, 1000)
