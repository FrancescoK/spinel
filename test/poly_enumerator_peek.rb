# peek on an Enumerator held in a boxed local (one the program also gives
# another class) answered NoMethodError, where next already worked.
e = ARGV.empty? ? (1..3).each : "x"
p e.next
p e.peek
p e.next
p e.peek
p e.next
begin
  e.peek
rescue StopIteration
  puts "stopped"
end
s = ARGV.empty? ? "str" : [1].each
begin
  s.peek
rescue NoMethodError => err
  puts err.message
end
