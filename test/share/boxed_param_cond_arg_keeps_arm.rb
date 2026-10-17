# --share-strings: a conditional handed to a boxed parameter (one that is also
# called with an Integer) is the selected arm's own String, whatever its
# predicate calls: a handle changed in place, a String Range's endpoint, an
# instance variable's String. A call in the predicate made the argument a
# temp ahead of the call, holding the arm's bytes, and the parameter's box
# was another String: equal? said so, and a change through the parameter
# did not reach the arm.
def f(x, y) = [x, y]
f(1, 2)
@iv = +"iv"
@iv << "?"
q = +"q"
a = +"a"; b = +"c"; r = a..b
b << "x"
a2 = +"xa"; b2 = +"xb"; r2 = a2..b2
p f((q.empty? ? q : @iv), 7)[0].equal?(@iv)
p f((@iv.size > 1 ? @iv : q), 7)[0].equal?(@iv)
p f((@iv.size > 1 ? r.end : q), 7)[0].equal?(b)
p f((@iv.size > 1 ? r2.end : q), 7)[0].equal?(b2)
p f((@iv.size > 1 ? q : r.end), 7)[0].equal?(q)
p f((q.size == 1 && @iv), 7)[0].equal?(@iv)
p f((q.size == 0 || r.end), 7)[0].equal?(b)
p f((case q.size when 1 then r.end else q end), 7)[0].equal?(b)
p f((if @iv.size > 1 then @iv else q end), 7)[0].equal?(@iv)
p f((unless @iv.size > 1 then q else @iv end), 7)[0].equal?(@iv)
x = f((@iv.size > 1 ? @iv : q), 7)
x[0] << "!"
p @iv
y = f((@iv.size > 1 ? r.end : q), 7)
y[0] << "#"
p b
