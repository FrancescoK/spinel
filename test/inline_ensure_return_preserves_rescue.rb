# Returning through an inlined method's ensure leaves the caller's handlers
# live. Later exceptions must reach their own rescue, and a caller's ensure
# must wait until the caller leaves its protected body.
def ensured_value
  begin
    yield
    return 1
  ensure
    puts "ensure"
  end
end

begin
  ensured_value { :blk }
rescue
  puts "wrong first rescue"
end
begin
  raise ArgumentError
rescue => e
  puts "rescued #{e.class}"
end
puts "end"

def ensured_nil
  begin
    yield
    return
  ensure
    puts "nil ensure"
  end
end

def rc(v) = ($a = v)
def ensured_call
  begin
    yield
    return rc(2)
  ensure
    puts "call ensure"
  end
end

def without_block
  begin
    return 3
  ensure
    puts "no block ensure"
  end
end

def raising_ensure
  begin
    yield
    return 4
  ensure
    raise TypeError, "ensure raised"
  end
end

def y = yield(1)

# Both later rescues belong to the same method as the protected call.
def check_later(label)
  puts label
  begin
    yield
    puts "after call"
  rescue => e
    puts "call rescued #{e.class}: #{e.message}"
  end
  begin
    raise ArgumentError, "later"
  rescue => e
    puts "rescued #{e.class}: #{e.message}"
  end
  begin
    y { |a, k:| a }
  rescue => e
    puts "rescued #{e.class}: #{e.message}"
  end
end

check_later("value statement") { ensured_value { :blk } }
check_later("value expression") { p ensured_value { :blk } }
check_later("bare statement") { ensured_nil { :blk } }
check_later("bare expression") { p ensured_nil { :blk } }
check_later("call statement") { ensured_call { :blk } }
check_later("call expression") { p ensured_call { :blk }; p $a }
check_later("no block statement") { without_block }
check_later("no block expression") { p without_block }
check_later("next statement") { ensured_value { next :next } }
check_later("next expression") { p ensured_value { next :next } }
check_later("break statement") { ensured_value { break :break } }
check_later("break expression") { p ensured_value { break :break } }
check_later("bare break") { p ensured_value { break } }
check_later("raising statement") { raising_ensure { :blk } }
check_later("raising expression") { p raising_ensure { :blk } }

check_later("caller ensure statement") do
  begin
    ensured_value { :blk }
    puts "still in caller"
  ensure
    puts "caller ensure"
  end
end
check_later("caller ensure expression") do
  begin
    p ensured_value { :blk }
    puts "still in caller"
  ensure
    puts "caller ensure"
  end
end

# A rescue between two ensures must be popped as well. Repetition exposes
# a leaked frame even when the next freshly pushed handler still works.
def nested_ensures
  begin
    begin
      begin
        yield
        return 5
      ensure
        $inner += 1
      end
    rescue
      puts "wrong nested rescue"
    end
  ensure
    $outer += 1
  end
end

$inner = 0
$outer = 0
200.times do
  begin
    nested_ensures { :blk }
  rescue
    puts "wrong repetition rescue"
  end
end
p [$inner, $outer]
check_later("nested expression") { p nested_ensures { :blk } }

# An exception raised by an inner ensure still visits the surrounding
# rescue before the outer ensure, even though a return was pending.
check_later("nested raising ensure") do
  begin
    begin
      raising_ensure { :blk }
    rescue TypeError => e
      puts e.message
    end
    puts "after inner rescue"
  ensure
    puts "outer ensure"
  end
end
puts "done"
