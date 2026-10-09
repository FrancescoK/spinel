# `rows[i]` is no element read where the program defines Array#[]: it calls
# the program's method, and what that answers is a call's result, held by no
# variable while it is boxed for the rest parameter or for String#%.
#
# Each line is the number of calls, of 300, that answered something else.
# spinel: gc-stress

SIZE = 2000
CALLS = 300
$base = 0

def floats(i)
  a = []
  k = 0
  while k < SIZE
    a << i + k + 0.5
    k += 1
  end
  a
end

class Array
  def [](i) = floats(i + $base)
end

def take(*items) = items

def rest_of_own_index
  rows = [floats(0), floats(1)]
  bad = 0
  n = 0
  while n < CALLS
    $base = n
    r = take(*rows[1])
    bad += 1 unless r.size == SIZE && r.sum == SIZE * (n + 1) + SIZE * SIZE / 2.0
    n += 1
  end
  bad
end

def format_of_own_index
  rows = [floats(0), floats(1)]
  fmt = "%.1f " * SIZE
  bad = 0
  n = 0
  while n < CALLS
    $base = n
    s = fmt % rows[1]
    bad += 1 unless s.start_with?("#{n + 1.5} #{n + 2.5} ") && s.end_with?(" #{n + SIZE + 0.5} ")
    n += 1
  end
  bad
end

puts "the program's Array#[] into a rest parameter: #{rest_of_own_index}"
puts "the program's Array#[] formatted: #{format_of_own_index}"
