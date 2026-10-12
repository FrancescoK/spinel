# An operator or a method called on an Integer slot while it holds nil
# raises CRuby's NoMethodError naming it: `+`, `<<`, `>>`, `-@`, `<`,
# `even?`, and `~`, which read the slot as a strict Integer argument and
# raised the conversion's TypeError (#7444). A Float slot does the same.
def try
  yield
rescue NoMethodError, TypeError => e
  puts "#{e.class}: #{e.message}"
end
class C
  def initialize(n) = @n = (n > 0 ? n : nil)
  def shl = @n << 1
  def shr = @n >> 1
  def neg = -@n
  def inv = ~@n
  def plus = @n + 1
  def cmp = @n < 3
  def even = @n.even?
end
[C.new(2), C.new(0)].each do |c|
  try { p c.shl }
  try { p c.shr }
  try { p c.neg }
  try { p c.inv }
  try { p c.plus }
  try { p c.cmp }
  try { p c.even }
end
x = ARGV.size > 5 ? 1 : nil
try { p ~x }
try { p x.abs }
y = ARGV.size > 5 ? 1.5 : nil
try { p y * 2 }
