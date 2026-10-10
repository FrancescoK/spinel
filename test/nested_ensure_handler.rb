# spinel: gc-stress
# spinel: share
def nested_value
  begin
    begin
      raise "value"
    ensure
      puts "inner"
    end
  rescue => e
    e.message
  ensure
    puts "outer"
  end
end
puts nested_value

def nested_clause
  begin
    raise "first"
  rescue
    begin
      raise "second"
    ensure
      GC.start
    end
  ensure
    return :done
  end
end
100.times { nested_clause }
p nested_clause

M = Mutex.new
begin
  M.synchronize { raise "locked" }
rescue => e
  p [e.message, M.locked?]
ensure
  puts "lock ensure"
end

begin
  [1, 2].reject! { |i| raise "filter #{i}" if i == 1; false }
rescue => e
  p e.message
ensure
  puts "filter ensure"
end

begin
  begin
    [1, 2].delete_if { |i| raise "direct #{i}" if i == 1; false }
  ensure
    puts "direct inner"
  end
rescue => e
  p e.message
ensure
  puts "direct outer"
end

begin
  begin
    raise "pass"
  ensure
    puts "pass inner"
  end
ensure
  puts "pass outer"
end rescue puts "pass rescued"

p $!
