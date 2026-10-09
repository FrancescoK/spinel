l = -> { y = +"a"; @k = y; y }
r = l.call
r << "!"
p @k
