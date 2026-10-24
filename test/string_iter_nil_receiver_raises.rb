# A String iterator with a block on a receiver that is nil (an element past
# the end) raises NoMethodError: the loop read nil as an empty String and
# ran nothing.
a = [+"s", +"t"]
%w[each_char each_byte each_line chars bytes].each { }
begin
  a[5].each_char { }
  p :no_raise
rescue NoMethodError => e
  p e.message
end
begin
  a[5].each_byte { }
rescue NoMethodError => e
  p e.message
end
begin
  a[7].each_line { }
rescue NoMethodError => e
  p e.message
end
n = 0
a[0].each_char { n += 1 }
"xyz".each_char { n += 1 }
p n
