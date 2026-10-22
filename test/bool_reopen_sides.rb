# A method that TrueClass or FalseClass defines itself is called for that
# value only. The other value answers what the builtin answers, or raises
# NoMethodError when the builtin has no such method.

class TrueClass
  def <=>(o) = 42
  def to_s = "yes"
  def ==(o) = :eq
  def hi = "T"
  def add(a, b = 3) = a + b
end

class FalseClass
  def lo(x) = x + 1
  def &(o) = :and
end

module Sure
  def sure? = "mod"
end

class TrueClass
  include Sure
end

def flag(n)
  puts "flag #{n}"
  n > 1
end

# literal receivers
p(true <=> true)
p(false <=> false)
puts true.to_s
puts false.to_s
p(true == true)
p(false == false)
p true.hi
begin
  false.hi
rescue NoMethodError
  puts "false.hi: NoMethodError"
end
p false.lo(2)
begin
  true.lo(2)
rescue NoMethodError
  puts "true.lo: NoMethodError"
end

# values known only at run time; the receiver runs once
p(flag(2) <=> true)
p(flag(0) <=> false)
puts flag(2).to_s
puts flag(0).to_s
puts "#{flag(2)} #{flag(0)}"
p flag(0) & true
p flag(2) & true
p flag(2).add(1)
p flag(2).add(1, 1)
p flag(2).sure?
begin
  flag(0).sure?
rescue NoMethodError
  puts "false.sure?: NoMethodError"
end
if flag(2) == true then puts "then" else puts "else" end
x = flag(0) ? 1 : 2
p x

# boxed values in an Array
a = [true, false]
p a.map { |v| v <=> v }
a.each { |v| puts v.to_s }
p a.map(&:to_s)
