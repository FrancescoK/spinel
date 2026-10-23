# A multiple write at the top level types the main object's ivars, as a
# single write does: `@a << "#"` is a String append, not an Array push
s = +"abc"
@a, @b = s, +"y"
@a << "#"
p @a, @b, s
@n, @m = 1, 2.5
p @n + 1, @m * 2
@x, (@y, @z) = :k, [3, "w"]
p @x, @y, @z
def pair = [+"p", 7]
@p, @q = pair
@p << "!"
p @p, @q
