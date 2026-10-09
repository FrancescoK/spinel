# spinel: int64
# spinel: share
# spinel: gc-minor
# Checked conversions also apply to Bignums and boxed collection indices.
[Float::INFINITY, -Float::INFINITY, Float::NAN].each do |n|
  b = [2**70, "x"][0]
  a = [[1, 2], {}][0]
  strings = [+"ab", []]
  begin
    (2**70).round(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    (2**70).floor(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    (2**70).ceil(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    (2**70).truncate(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    (2**70).digits(n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    (2**70)[n]
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    (2**70)[0, n]
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    b[n]
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    a[n]
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    a[n] = 3
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    a.fill(3, n)
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    strings[0][n] = "x"
    puts "no raise"
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end
