# spinel: gc-stress
# spinel: share
def raising_else(i)
  begin
    raise "body" if i == 1
    :body
  rescue
    :rescued
  else
    raise "else" if i == 2
    :else
  ensure
    puts "ensure #{i}"
    GC.start
  end
end
p raising_else(0), raising_else(1)
begin
  raising_else(2)
rescue => e
  p e.message
end

def swallow_else
  begin
    1
  rescue
  else
    raise "swallowed"
  ensure
    return :done
  end
end
100.times { swallow_else }
p swallow_else

begin
  begin
    puts "body"
  rescue
    puts "wrong rescue"
  else
    begin
      raise "nested"
    ensure
      puts "inner"
    end
  ensure
    puts "outer"
  end
rescue => e
  p e.message
end

x = begin
  1
rescue
  2
else
  "value"
ensure
  GC.start
end
p x

seen = []
3.times do |i|
  begin
    i
  rescue
  else
    next if i < 2
    seen << i
  ensure
    seen << :ensure
  end
end
p seen

value = catch(:done) do
  begin
    1
  rescue
  else
    throw :done, :thrown
  ensure
    puts "throw ensure"
  end
end
p value, $!
