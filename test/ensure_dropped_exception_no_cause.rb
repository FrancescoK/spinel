# An ensure body that is left by a return, a break, a next, a throw or a
# proc's return drops the exception it was running for. A raise after that
# does not take the dropped exception as its cause.

def later
  raise "later"
rescue => e
  e.cause.inspect
end

def by_return
  begin
    raise "dropped"
  ensure
    return 1
  end
end
by_return
puts "return: #{later}"

[1].each do |x|
  begin
    raise "dropped"
  ensure
    break
  end
end
puts "break: #{later}"

[1, 2].each do |x|
  begin
    raise "dropped"
  ensure
    next
  end
end
puts "next: #{later}"

i = 0
while i < 2
  i += 1
  begin
    raise "dropped"
  ensure
    next
  end
end
puts "next in a while: #{later}"

catch(:out) do
  begin
    raise "dropped"
  ensure
    throw :out
  end
end
puts "throw: #{later}"

def from_block
  [1].each do |x|
    begin
      raise "dropped"
    ensure
      return 1
    end
  end
end
from_block
puts "return from a block: #{later}"

def from_proc
  pr = proc do
    begin
      raise "dropped"
    ensure
      return 1
    end
  end
  pr.call
end
from_proc
puts "a proc's return: #{later}"

def pass
  yield 1
  yield 2
end
def from_yield
  pass do |x|
    begin
      raise "dropped"
    ensure
      break
    end
  end
end
from_yield
puts "break out of a yield: #{later}"

# two deep: the inner ensure drops its exception, the outer one's is still
# in flight and is the cause of what the outer body raises
def two_deep
  begin
    raise "outer"
  ensure
    [1].each do |x|
      begin
        raise "inner"
      ensure
        break
      end
    end
    raise "from the outer ensure"
  end
end
begin
  two_deep
rescue => e
  puts "two deep: #{e.message}, cause #{e.cause.inspect}"
end

def two_deep_throw
  begin
    raise "outer"
  ensure
    catch(:out) do
      begin
        raise "inner"
      ensure
        throw :out
      end
    end
    raise "from the outer ensure"
  end
end
begin
  two_deep_throw
rescue => e
  puts "two deep, a throw: #{e.message}, cause #{e.cause.inspect}"
end

# an ensure body that is not left: its raise takes the one in flight
begin
  begin
    raise "first"
  ensure
    raise "second"
  end
rescue => e
  puts "not left: #{e.message}, cause #{e.cause.inspect}"
end

# an ensure body that ends: nothing is in flight after it
begin
  begin
    raise "first"
  ensure
    x = 1
  end
rescue => e
  puts "ended: #{e.message}, cause #{e.cause.inspect}"
end
puts "after it: #{later}"

n = 0
200.times do
  by_return
  n += 1 if later == "nil"
end
p n
