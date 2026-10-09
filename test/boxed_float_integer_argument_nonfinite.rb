# spinel: share
# spinel: gc-minor
# Boxed arguments retain each integer conversion protocol.
[Float::INFINITY, -Float::INFINITY, Float::NAN, 2.5, "bad"].each do |n|
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
    p 1 << n
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end

# A mixed receiver exercises boxed numeric dispatch as well as boxed digits.
[42, 4.2, nil].each do |receiver|
  unless receiver.nil?
    [Float::INFINITY, -Float::INFINITY, Float::NAN].each do |n|
      begin
        p receiver.round(n)
      rescue => e
        puts "#{e.class}: #{e.message}"
      end
      begin
        p receiver.floor(n)
      rescue => e
        puts "#{e.class}: #{e.message}"
      end
      begin
        p receiver.ceil(n)
      rescue => e
        puts "#{e.class}: #{e.message}"
      end
      begin
        p receiver.truncate(n)
      rescue => e
        puts "#{e.class}: #{e.message}"
      end
      begin
        p receiver.round(n, half: :even)
      rescue => e
        puts "#{e.class}: #{e.message}"
      end
    end
  end
end
