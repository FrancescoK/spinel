# A String bang method on a boxed receiver that holds no String raises
# CRuby's NoMethodError. The value-form bang (upcase!, sub!, succ!, ...)
# read the receiver through its #to_s rendering, applied the transform to
# that, and wrote the result back into the box as if it held a string: a
# Symbol, Integer or Float crashed, nil raised FrozenError, and an Array or
# Hash answered its transformed inspect text.

def up(s) = s.upcase!
def ch(s) = s.chomp!
def sb(s) = s.sub!("b", "x")
def sq(s) = s.squeeze!
def nx(s) = s.succ!

def try
  p yield
rescue NoMethodError => e
  puts e.message
end

p up(+"ab"), ch(+"ab\n"), sb(+"ab"), sq(+"aab"), nx(+"az")
[:a, 5, nil, [1], 1.5, {a: 1}].each do |v|
  try { up(v) }
  try { ch(v) }
  try { sb(v) }
  try { sq(v) }
  try { nx(v) }
end

# a local, an ivar and an element read
s = ARGV.size > 5 ? +"ab" : :a
try { s.downcase! }
try { s.tr!("a", "b") }
s = ARGV.size > 5 ? :a : +"ab"
p s.capitalize!, s

class Box
  def initialize(v) = @v = v
  def strip = @v.strip!
end
p Box.new(+" ab ").strip
try { Box.new(3).strip }

a = [+"ab", :k, 7]
p a[0].delete!("a"), a
try { a[1].delete_suffix!("k") }
try { a[2].next! }
