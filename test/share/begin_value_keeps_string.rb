# An element written from a begin block's String is that String (#9258)
s = +"abc"
a = [1, 2]
a[1] = begin; s << "y"; s; end
s << "!"
p a
