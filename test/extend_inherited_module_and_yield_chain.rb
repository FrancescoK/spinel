# A module a superclass already extends is among the subclass singleton's
# ancestors: extending it again after another module leaves that later
# module's method first, and its super reaches the superclass's copy.
module M1; def bar = [:m1]; end
module M2; def bar = [:m2, *super]; end
class X; extend M1; end
class Y < X; extend M2; extend M1; end
p Y.bar
p X.bar

# A block value yielded at the end of three modules chained by a bare super:
# the middle copy's yield type comes through the super that lands on it,
# for extend and for include alike.
module A1; def who = yield(1); end
module B1; def who = [:b1, super]; end
module C1; def who = [:c1, super]; end
class Q; extend A1; extend B1; extend C1; end
p Q.who { |v| v * 10 }
class R; include A1; include B1; include C1; end
p R.new.who { |v| v + 0.5 }
