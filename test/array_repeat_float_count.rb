# spinel: share
# Array#* with a Float count truncates it toward zero (NUM2LONG); a negative
# or non-finite count raises.
def try
  p yield
rescue => e
  p [e.class, e.message]
end

try { [1, 2] * 2.5 }
try { [] * 2.5 }
try { [1, 2] * 0.9 }
try { [1, 2] * -0.9 }
try { [1, 2] * -0.0 }
try { [1.5, :x, nil] * 1.8 }
[-1.1, Float::NAN, Float::INFINITY, -Float::INFINITY, 1e30, -1e30].each do |count|
  try { [1, 2] * count }
end

try { [1.5, 2.5] * 2.5 }
try { %w[a b] * 1.8 }
try { [1, :x, nil] * 2.5 }
n = 2.5
try { [1, 2] * n }
def repeated(n); [1, 2] * n; end
try { repeated(2.5) }

def receiver
  puts "receiver"
  [1, 2]
end
def count
  puts "count"
  2.5
end
try { receiver * count }
class Count
  def to_int
    puts "to_int"
    2
  end
end
try { [1, 2] * Count.new }
try { [1, 2] * 2 }
try { %w[a b] * "|" }

m = 2.5
m = nil if ARGV.empty?
try { [1, 2] * m }
a = [1, 2]
a = nil if ARGV.empty?
try { a * 2.5 }
