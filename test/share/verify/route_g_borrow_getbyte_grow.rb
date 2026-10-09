@b = +"abc"
def f(s) = (s.getbyte(0) + s.bytesize)
x = @b
10.times { x << "q" * 100; p f(@b) if x.size > 900 }
