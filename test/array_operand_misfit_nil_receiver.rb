# spinel: gc-stress
# An Array call with an operand no Array conversion takes (a nil, a boolean, an
# Integer) evaluates its receiver and every operand, then raises. A receiver
# that is nil raises NoMethodError first, whatever the operands hold: a boxed
# operand ahead of the misfit that is no Array was converted ahead of the
# receiver's test and raised its TypeError instead. With the receiver set, the
# TypeError of the first operand that is no Array is still the one raised.
# concat, union, product, difference and intersection take several operands;
# replace takes one, which is the misfit itself.
class Q
  def fill; @a = [1]; end

  def concat_nil(x) = @a.concat(x, nil)
  def union_true(x) = @a.union(x, true)
  def product_nil(x) = @a.product(x, nil)
  def concat_int(x) = @a.concat(x, 3)
  def replace_nil(_x) = @a.replace(nil)
  def difference_nil(x) = @a.difference(x, nil)
  def intersection_nil(x) = @a.intersection(x, nil)
end

def attempt(q, m, v)
  q.send(m, v)
rescue => e
  puts "#{m} #{v.inspect}: #{e.class}: #{e.message[0, 50]}"
end

q = Q.new
%i[concat_nil union_true product_nil concat_int difference_nil intersection_nil].each do |m|
  [5, "s", [2]].each { |v| attempt(q, m, v) }
end
attempt(q, :replace_nil, nil)
q.fill
%i[concat_nil union_true product_nil concat_int difference_nil intersection_nil].each do |m|
  [5, [2]].each { |v| attempt(q, m, v) }
end
attempt(q, :replace_nil, nil)
