# A method whose body always raises -- an Array operator given an operand that
# is no Array, a call on nil -- stays in a runtime-name send's dispatch and
# raises from inside it. Its value type is void, which the dispatch read as
# "did not resolve on this receiver" and dropped the method: the send raised
# "undefined method" for a method the class defines. A nil receiver, held by
# an ivar no write of the program leaves nil, raises NoMethodError for the
# method, ahead of the operand's TypeError, as a call would.
class K
  def setup = (@a = [3, 1, 2]; self)
  def minus_nil = @a - nil
  def plus_true = @a + true
  def and_nil = @a & nil
  def or_int = @a | 1
  def diff_nil = @a.difference(nil)
  def union_nil = @a.union(nil)
  def inter_int = @a.intersection(1)
  def concat_nil = @a.concat(nil)
  def nil_call = nil.foo
  def plain_raise = raise("x")
  def int_raise = Integer("x")
  def tail
    n = 2
    n.to_s
    @a - nil
  end
end

def show(s, k)
  r = k.send(s)
  puts "#{s}: #{r.inspect}"
rescue NoMethodError, TypeError, RuntimeError, ArgumentError => e
  puts "#{s}: #{e.class} #{e.message}"
end

# (NilClass answers & and |, so those two are tried on the filled receiver alone)
names = %i[minus_nil plus_true diff_nil union_nil inter_int concat_nil nil_call plain_raise
           int_raise tail]
names.each { |s| show(s, K.new) }
(names + %i[and_nil or_int]).each { |s| show(s, K.new.setup) }

# the same methods called directly
[K.new, K.new.setup].each do |k|
  begin
    k.minus_nil
  rescue NoMethodError, TypeError => e
    puts "direct: #{e.class} #{e.message}"
  end
  begin
    k.diff_nil
  rescue NoMethodError, TypeError => e
    puts "direct: #{e.class} #{e.message}"
  end
end

# a name read from a variable, and public_send
name = names[ARGV.size]
begin
  K.new.setup.public_send(name)
rescue TypeError => e
  puts "public_send #{name}: #{e.message}"
end
