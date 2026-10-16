# --share-strings: a proc or lambda whose last expression is a push onto an
# instance variable's Array answers that Array, which stays the general Array
# once a String in it is changed in place (the handle form is given up).
# The answer was taken as an Array of handles and read as one.
class C
  def initialize
    @s = +"iv"
    @k = []
  end
  def run
    st = proc { |v| @k << v }
    r = st.call(@s)
    @k[0] << "!"
    p [@s, @k, @s.equal?(@k[0]), r.equal?(@k)]
  end
  def lam
    st = lambda { |v| @k << v }
    r = st.call(@s)
    @k[0] << "?"
    p [@s, @k, r.equal?(@k)]
  end
end
C.new.run
C.new.lam
# ...and the methods and procs whose value is such a call answer the general
# Array too: a method ending in a proc's call, the call printed, a chain of a
# method, a proc and a method, and two classes.
class D
  def initialize = (@s = +"iv"; @k = [])
  def run
    st = proc { |v| @k << v }
    st.call(@s)
    @k[0] << "!"
    q = proc { @k }
    q.call
  end
  def show
    st = proc { |v| @k << v }
    st.call(@s)
    @k[0] << "?"
    q = proc { @k }
    p q.call
  end
end
p D.new.run
D.new.show
class E
  def initialize = (@s = +"ch"; @k = [])
  def data = @k
  def run
    st = proc { |v| @k << v }
    st.call(@s)
    @k[0] << "!"
    q = proc { data }
    q.call
  end
  def top = run
end
e = E.new
x = e.top
p x, x.equal?(e.data)
class F
  def initialize = (@t = +"ff"; @j = [])
  def run
    st = lambda { |v| @j << v }
    st.call(@t)
    @j[0] << "#"
    q = -> { @j }
    q.call
  end
end
p F.new.run, E.new.top
