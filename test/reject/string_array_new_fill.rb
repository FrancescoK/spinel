# Array.new(n, s) fills every slot with s itself, one String. The slots
# were copies and s stayed "abc": refused, not compiled wrong.
s = +"abc"
a = Array.new(2, s)
a[1] << "!"
p s
