# An error's class held in a variable while Strings are made. `e.class` named
# the class with a fresh copy on the string heap, and a Class value is a plain
# struct no root knows: the copy was collected under the variable, and the
# class then answered with whichever String took its place.
def fail_with(i)
  raise ArgumentError, "bad #{i}" if i % 2 == 0
  raise KeyError, "missing #{i}"
end

def churn(n)
  keep = []
  j = 0
  while j < n
    keep << "junk-" + (j % 10).to_s + "-junk-"
    j += 1
  end
  keep.size
end

def shown(k, n)
  churn(n)
  k.to_s
end

class Holder
  def initialize(k) = @k = k
  def shown(n)
    churn(n)
    @k.to_s
  end
end

to_s = name = inspect = interp = same = param = ivar = 0
1000.times do |i|
  want = i % 2 == 0 ? "ArgumentError" : "KeyError"
  begin
    fail_with(i)
  rescue => e
    k = e.class
    churn(400)
    to_s += 1 unless k.to_s == want
    k = e.class
    churn(400)
    name += 1 unless k.name == want
    k = e.class
    churn(400)
    inspect += 1 unless k.inspect == want
    k = e.class
    churn(400)
    interp += 1 unless "#{k}!" == want + "!"
    k = e.class
    churn(400)
    same += 1 unless (k == ArgumentError) == (i % 2 == 0) && (k == KeyError) == (i % 2 == 1)
    param += 1 unless shown(e.class, 400) == want
    ivar += 1 unless Holder.new(e.class).shown(400) == want
  end
end
p to_s, name, inspect, interp, same, param, ivar

# the name is the class's own, and a String made from it is the caller's
begin
  fail_with(0)
rescue => e
  s = e.class.to_s
  s << "!"
  t = e.class.to_s
  t.upcase!
  p s, t, e.class.to_s, e.class.name, e.class
  p e.class.to_s.frozen?, e.class.name.frozen?, e.class.name.equal?(ArgumentError.name)
end

# the class outlives the rescue: returned by a method, held at the top level
# while Strings are made, then compared and raised
class Slow < StandardError; end

def class_of_a_rescue
  raise Slow, "orig"
rescue => e
  e.class
end

k = class_of_a_rescue
a = []
60000.times { |i| a << ("s" + i.to_s) if i % 7 == 0 }
p [k, k == Slow, a.size]
begin
  raise k, "again"
rescue Slow => z
  p [z.class, z.message]
end

# and raised at once: the new error carries the name, and is read after the
# Strings are made
def again(e)
  raise e.class, "m"
end

x = nil
begin
  begin
    raise Slow, "orig"
  rescue => e
    again(e)
  end
rescue StandardError => y
  x = y
end
a = []
60000.times { |i| a << ("t" + i.to_s) if i % 7 == 0 }
p [x.class, x.message, x.is_a?(Slow), a.size]
begin
  raise x
rescue Slow
  puts "rescued Slow"
rescue
  puts "rescued another"
end

# more error classes than the table of kept names starts with room for
class E0 < StandardError; end
class E1 < StandardError; end
class E2 < StandardError; end
class E3 < StandardError; end
class E4 < StandardError; end
class E5 < StandardError; end
class E6 < StandardError; end
class E7 < StandardError; end
class E8 < StandardError; end
class E9 < StandardError; end
class E10 < StandardError; end
class E11 < StandardError; end
def raise_nth(i)
  case i
  when 0 then raise E0, "m"
  when 1 then raise E1, "m"
  when 2 then raise E2, "m"
  when 3 then raise E3, "m"
  when 4 then raise E4, "m"
  when 5 then raise E5, "m"
  when 6 then raise E6, "m"
  when 7 then raise E7, "m"
  when 8 then raise E8, "m"
  when 9 then raise E9, "m"
  when 10 then raise E10, "m"
  else raise E11, "m"
  end
end
names = []
36.times do |i|
  begin
    raise_nth(i % 12)
  rescue => e
    names << e.class.to_s
  end
end
p names.uniq.size, names[0], names[11], names[35]
