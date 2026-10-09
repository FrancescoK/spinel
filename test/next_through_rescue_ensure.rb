# A next or break counts the rescue clauses it leaves from where its loop or
# ensure began, not by frame depth: a next in a block inside a rescue left
# that rescue too and cleared its $! (#8208). A next deferred through an
# ensure popped one frame where a begin stood between it and the outer
# ensure, and a loop of them overflowed the frame stack (#8207).
begin
  raise "x"
rescue
  [1, 2].each { |i| next if i == 1 }
  p $!
  [1, 2].each { |i| break if i == 2 }
  p $!
  i = 0
  while i < 3
    i += 1
    next if i == 1
  end
  p $!
end

n = 0
1000.times do
  begin
    begin
      begin
        next
      ensure
        n += 1
      end
    rescue
    end
  ensure
    n += 1
  end
end
p n

m = 0
[1, 2, 3].each do |i|
  begin
    begin
      raise "in #{i}"
    rescue => e
      begin
        next if i == 2
      ensure
        m += 1
      end
      p [i, $!.message]
    end
  ensure
    m += 10
  end
end
p m

def leave
  begin
    raise "outer"
  rescue
    [1].each do
      begin
        return $!.message
      ensure
        nil
      end
    end
  end
end
p leave
p $!
