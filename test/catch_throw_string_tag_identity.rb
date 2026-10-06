# A String catch/throw tag matches by identity, as equal? does. By content
# an equal copy (`x.dup`) met the original and an argument-less catch's own
# tag met a copy of it, where CRuby raises UncaughtThrowError. A literal is
# one object per content (its block parameter meets it); a String that is
# shared and changed is still the one tag; and the uncaught message
# inspects a String tag as CRuby's does, not as a Symbol.
p catch("a") { throw "a", 1 }
p((catch(:a) { throw "a", 1 } rescue $!))
p((catch("a") { throw :a, 1 } rescue $!))
x = +"t"
p((catch(x) { throw x.dup, 1 } rescue $!))
p catch(x) { throw x, 3 }
x << "u"
p catch(x) { throw x, 4 }
p x
begin
  catch(:z) { throw "q", 2 }
rescue UncaughtThrowError => e
  p [e.tag, e.value, e.message]
end

# across a method, a container read and a block parameter
def thr(t) = throw(t, 7)
s = +"m"
s << "n"
p catch(s) { thr(s) }
def cat(t) = catch(t) { yield }
u = +"k"
u << "!"
p cat(u) { throw u, 8 }
a = [+"e", 1]
p catch(a[0]) { throw a[0], 9 }
y = +"p"
p catch(y) { |t| throw t, 5 }
p catch("lit") { |t| throw t, 6 }
z = [+"bx", 1][0]
p catch(z) { |t| throw t, 7 }

# an argument-less catch's tag
p catch { |tag| throw tag, 1 }
r = catch do |t1|
  catch { |t2| throw t1, :outer }
  :no
end
p r
p((catch { |tag| throw tag.dup, 2 } rescue $!.class))
