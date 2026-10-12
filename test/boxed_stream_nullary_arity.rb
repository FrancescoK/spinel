# A stream read back out of a container, given an argument by a method that
# takes none: ArgumentError after the arguments run, the stream left open
f = File.open(__FILE__)
o = [f, 1].first
%w[close flush fileno eof? closed? path to_path tty? isatty rewind].each do |m|
  begin
    o.__send__(m, 1)
    puts "#{m}: no raise"
  rescue ArgumentError => e
    puts "#{m}: #{e.message}"
  end
end
def side
  puts "side"
  1
end
begin
  o.close(side)
rescue ArgumentError => e
  puts e.message
end
p f.closed?
q = [1, f].first
begin
  q.close(side)
rescue NoMethodError => e
  puts e.class
end
d = [Dir.new(__dir__), 1].first
begin
  d.close(1)
rescue ArgumentError => e
  puts "dir: #{e.message}"
end
begin
  d.fileno(1, 2)
rescue ArgumentError => e
  puts "dir: #{e.message}"
end
qq = [Queue.new, 1].first
begin
  qq.closed?(1)
rescue ArgumentError => e
  puts "queue: #{e.message}"
end
s = ["str", 1].first
begin
  s.flush(1)
rescue NoMethodError => e
  puts "str: #{e.class}"
end
begin
  d.rewind(1)
rescue ArgumentError => e
  puts "dir: #{e.message}"
end
en = [[1, 2].each, 1].first
begin
  en.rewind(1)
rescue ArgumentError => e
  puts "enumerator: #{e.message}"
end
# an empty double splat passes nothing
h = {}
p o.path(**h) == __FILE__
p o.close(**h)
p f.closed?
