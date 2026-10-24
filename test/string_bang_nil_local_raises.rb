# A String bang as a statement on a String variable that holds nil
# (`x = a[5]; x.upcase!`) raises NoMethodError: the in-place transform read
# the nil handle and the program crashed.
a = [+"x"]
x = a[5]
begin
  x.upcase!
rescue NoMethodError => e
  p e.message
end
y = a[0]
y.upcase!
p a
