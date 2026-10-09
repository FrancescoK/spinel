# spinel: int64
# Float precision is evaluated before keywords and converted after them.
def mode
  puts "half"
  :even
end
begin
  p 25.round((puts "precision"; 0.0), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round((puts "precision"; 0), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round((puts "precision"; Float::INFINITY), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round((puts "precision"; 0.0), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round((puts "precision"; 0), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round((puts "precision"; Float::INFINITY), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round((puts "precision"; -1.0), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round((puts "precision"; 1.0), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round((puts "precision"; -Float::INFINITY), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round((puts "precision"; Float::NAN), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round((puts "precision"; -1.0), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round((puts "precision"; 1.0), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round((puts "precision"; -Float::INFINITY), half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round((puts "precision"; Float::NAN), half: mode)
rescue StandardError => e
  puts e.class
end
# A precision held in a variable is converted after the keyword has run.
inf = Float::INFINITY
ninf = -Float::INFINITY
nan = Float::NAN
one = 1.0
begin
  p 25.round(inf, half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round(ninf, half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round(nan, half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 25.round(one, half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round(inf, half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round(ninf, half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round(nan, half: mode)
rescue StandardError => e
  puts e.class
end
begin
  p 2.5.round(one, half: mode)
rescue StandardError => e
  puts e.class
end
