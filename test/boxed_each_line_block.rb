# each_line with a block on a String held in a mixed Array (a boxed
# receiver) yields each line and answers the receiver, as on a String;
# another kind of value raises NoMethodError.
s = [+"ab\ncd\nlast", 1][0]
s.each_line { |l| p l }
r = s.each_line { }
p r
n = 0
s.each_line { |l| n += l.size }
p n
a = []
s.each_line { a << _1.chomp }
p a
e = [+"", 2][0]
e.each_line { p :never }
x = [2, +"a"][0]
begin
  x.each_line { }
rescue NoMethodError => err
  puts err.message
end
