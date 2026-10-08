# A `return` in a Hash.new default block leaves the method that made the
# hash, as it does in a proc: the block runs when a key is missing, under
# whatever reads the hash.

def counted
  n = 0
  k = 0
  h = Hash.new { |hs, kk| k += 1; return n + 1000 if k == 3; n += 1; 0 }
  h[1]; h[2]; h[3]; h[4]
  n
end
p counted

# a block that reads only its two parameters
def doubled(a)
  h = Hash.new do |hs, k|
    if k > 2
      return :big
    end
    k * 2
  end
  a.map { |x| h[x] }
end
p doubled([1, 2])
p doubled([1, 2, 3])

def first_missing(keys)
  h = Hash.new { |_, k| return k }
  h[:a] = 1
  keys.each { |k| h[k] }
  :none
end
p first_missing([:a, :b, :c])
p first_missing([:a])

def stored
  h = Hash.new { |hash, k| return :early if k == :stop; hash[k] = k.to_s }
  h[:x]; h[:y]
  h[:stop]
  h.size
end
p stored

# no value, and two
def bare
  h = Hash.new { |hs, k| return if k == 2; k }
  h[1]; h[2]
  :end
end
p bare

def two
  h = Hash.new { |hs, k| return k, k + 1 if k == 2; k }
  h[1]; h[2]
  :end
end
p two

# an ensure on the way runs
def through_ensure(log)
  h = Hash.new { |hs, k| return :early if k == :stop; hs[k] = 1 }
  begin
    h[:a]
    h[:stop]
    log << :not_here
  ensure
    log << :ensure
  end
  :late
end
log = []
p through_ensure(log)
p log

# read by fetch and dig as well
def by_reads(k)
  h = Hash.new { |hs, kk| return "default #{kk}" if kk == :z; kk.to_s }
  a = h.fetch(:a, "x")
  b = h[k]
  c = h.dig(k)
  [a, b, c]
end
p by_reads(:b)
p by_reads(:z)

class Box
  def initialize(n)
    @n = n
  end

  def look(keys)
    h = Hash.new { |hs, k| return @n + k if k > 5; hs[k] = k }
    keys.each { |k| h[k] }
    h.size
  end

  define_method(:made) do |x|
    n = 1000
    h = Hash.new { |hs, k| return k + n if k > 2; k }
    h[x]
    :made_end
  end
end
p Box.new(100).look([1, 2, 3])
p Box.new(100).look([1, 7, 3])
p Box.new(0).made(5)
p Box.new(0).made(1)

# made in a block of the method
def in_each(a)
  n = 1000
  a.each do |x|
    h = Hash.new { |hs, k| return [:found, k + n] if k > 1; 0 }
    h[x]
  end
  :none
end
p in_each([1, 2, 3])
p in_each([0, 1])

# under a rescue modifier
def under_modifier
  n = 0
  k = 0
  h = Hash.new { |hs, kk| k += 1; (return n + 1000 if k == 3; n += 1) rescue n += 100; 0 }
  h[1]; h[2]; h[3]; h[4]
  n
end
t = 0
200.times { t += under_modifier }
p t

def once(i)
  h = Hash.new { |hs, k| return k if k.odd?; hs[k] = k * 2 }
  h[i]
  h[i] + 1
end
t = 0
300.times { |i| t += once(i) }
p t

# the method has returned: nothing to leave
def make
  Hash.new { |hs, k| return :gone if k == 3; k * 2 }
end
h = make
p h[1]
begin
  h[3]
rescue LocalJumpError => e
  puts "LocalJumpError: #{e.message}"
end
