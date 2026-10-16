# --share-strings: a bang on a boxed receiver (an element of an Array of
# mixed values, a Hash value) handed to a method's rest parameter answers the
# element's own String, or nil where nothing changed, and the method sees that
# String itself: appending to it changes the element. The bang runs once.
def ms(*t)
  t.each { |x| x << "!" if x }
  t
end
def mk(k, *t)
  t[0] << "?" if t[0]
  [k, t]
end
a = [+"ef", 1]
p ms(a[0].upcase!), a
p ms(a[0].upcase!), a
b = [+"GH", 2]
p mk(1, b[0].downcase!), b
p mk(2, b[0].downcase!), b
h = { k: +"ij", n: 3 }
p ms(h[:k].upcase!), h
c = [+"kl", 4]
p ms(+"x", c[0].upcase!, c[0].downcase!, +"y"), c
d = [+"mn", 5]
p ms(d[0].upcase! || +"z"), d
p ms(d[0].upcase! || +"z"), d
