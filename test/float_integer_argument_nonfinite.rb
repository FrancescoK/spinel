# spinel: int64
# spinel: share
# spinel: gc-minor
# Non-finite Float arguments are checked before conversion to an integer.
def check_float(n)
  begin
    p 42.round(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 42.floor(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 42.ceil(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 42.truncate(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 4.2.round(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 4.2.floor(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 4.2.ceil(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 4.2.truncate(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 42.round(n, half: :even)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 4.2.round(n, half: :down)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 42.digits(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p [1, 2].first(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p [1, 2].last(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p "ab" * n
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p [1, 2][n]
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p [1, 2].fetch(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p [1, 2].values_at(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p [1, 2].take(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p [1, 2].drop(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p "ab"[n]
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 42[n]
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 42[0, n]
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p sprintf("%d", n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p sprintf("%*s", n, "x")
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p 1 << n
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p n.to_i
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p n.to_int
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    p Signal.signame(n)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end

[Float::INFINITY, -Float::INFINITY, Float::NAN, 2.5].each do |n|
  check_float(n)
end

# Seeds use Float#to_int rather than the machine-integer argument protocol.
[Float::INFINITY, -Float::INFINITY, Float::NAN].each do |n|
  begin
    Random.new(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    Random.srand(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    srand(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    Random.bytes(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    Random.new(1).bytes(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    Random.urandom(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end

end

# Finite bit indices beyond the word still read the sign bit, not an error.
[1e100, -1e100, 2.5].each do |n|
  p 42[n]
  p((-42)[n])
  boxed = [n, "bad"][0]
  p 42[boxed]
  receiver = [42, "bad"][0]
  p receiver[n]
end
