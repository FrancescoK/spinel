class MyErr < StandardError; end
class Base < StandardError; end
class Sub < Base; end

def fr(a, b) = raise(a, b)
def fr2(a, b)
  raise a, b
end
class H
  def initialize(k, m); @k = k; @m = m; end
  def go = raise(@k, @m)
end
def fobj(e) = raise(e)

begin; fr(ArgumentError, "boom"); rescue => e; p e; end
begin; fr(MyErr, "mine"); rescue => e; p e; end
begin; fr2(ArgumentError, "b2"); rescue => e; p e; end
begin; k = RuntimeError; m = "loc"; raise k, m; rescue => e; p e; end
begin; k = MyErr; m = "loc2"; raise(k, m); rescue => e; p e; end
begin; H.new(TypeError, "iv").go; rescue => e; p e; end
begin; fobj(MyErr.new("inst")); rescue => e; p e; end
[ArgumentError, MyErr].each { |c| begin; raise c, "arr"; rescue => e; p e; end }

begin; fr(MyErr.new("orig"), "replaced"); rescue => e; p e; end
e0 = ArgumentError.new("x0")
begin; raise e0, "y0"; rescue => e; p e; p e0; end
begin; fr(RuntimeError, 42); rescue => e; p e; end
begin; fr(RuntimeError, nil); rescue => e; p e; end
begin; fr(RuntimeError, ""); rescue => e; p e; end
begin; fr(String, "no"); rescue => e; p e; end
begin; fr(Sub, "sub"); rescue Base => e; p e; end
begin; fr(KeyError, "k"); rescue IndexError => e; p e; end
