# spinel: gc-stress
# A String variable handed in parentheses, ahead of an argument that grows
# the String (moving its bytes) or gives the variable another String, is
# that String where the call binds it: through a splat into optional and
# rest parameters, as an instance or a global variable, to a yield, to a
# rest parameter and a block's, and to a builtin String or Hash method,
# also on a receiver of more than one class. The method's change shows
# through the other name, and a builtin reads the String as it is once
# every argument has run, as CRuby's do.
def g2(a = nil, b = 1, *r) = (a << "!"; 0)
def g3(a, b, c) = (a << "!"; 0)
n = 0
xs = [+"y"]

t = +"T"; t << ("a" * 100); o = t
g2((n += 1; t), *xs, (t.replace("r" * 4000); t = +"z"; GC.start; 9))
p o.size, o[-1], t, n

t = +"T"; t << ("a" * 100); o = t
g3((n += 1; t), *xs, (t << ("x" * 5000); 9))
p o.size, o[-1], t.equal?(o), n

class C
  def run(xs)
    n = 0
    @t = +"T"; @t << ("a" * 100); o = @t
    g2((n += 1; @t), *xs, (@t.replace("r" * 4000); @t = +"z"; GC.start; 9))
    p o.size, o[-1], @t, n
  end
end
C.new.run(xs)

$t = +"T"; $t << ("a" * 100); o = $t
g2((n += 1; $t), *xs, ($t.replace("r" * 4000); $t = +"z"; GC.start; 9))
p o.size, o[-1], $t, n

def yy(t)
  n = 0
  [0].each { yield((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; 9)) }
  [t, n]
end
t = +"T"; t << ("a" * 100); o = t
p yy(t) { |a, b| a << "!"; b }, o.size, o[-1]

u = "r" * 4000 + "x"
t = +"T"; t << ("a" * 100)
p u.sub((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "q")).size
t = +"T"; t << ("a" * 100)
p u.gsub((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "q")).size
t = +"T"; t << ("a" * 100)
p u.tr((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "q")).size
t = +"T"; t << ("a" * 100)
p u.count((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "r"))
t = +"T"; t << ("a" * 100)
p u.delete((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "r")).size
t = +"T"; t << ("a" * 100)
p u.index((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; 0))
t = +"T"; t << ("a" * 100)
p u.between?((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "z"))
t = +"T"; t << ("a" * 100)
p u.start_with?((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "r"))
t = +"T"; t << ("a" * 100)
w = u.dup; w[(n += 1; t)] = (t.replace("r" * 4000); t = +"z"; GC.start; "q")
p w.size
t = +"T"; t << ("a" * 100)
p u.send(:sub, (n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "q")).size

def r2(*r) = (r[0] << "!"; 0)
t = +"T"; t << ("a" * 100); o = t
r2((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; 9))
p o.size, o[-1]
t = +"T"; t << ("a" * 100); o = t
Object.new.instance_exec((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; 9)) { |a, b| a << "!" }
p o.size, o[-1]

v = [u, nil].first
t = +"T"; t << ("a" * 100)
p v.sub((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "q")).size
t = +"T"; t << ("a" * 100)
p v.count((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "r"))
t = +"T"; t << ("a" * 100)
p v.index((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; 0))
t = +"T"; t << ("a" * 100)
p v.start_with?((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "r"))
h = [{"r" * 4000 => 1, "z" => 2}, nil].first
t = +"T"; t << ("a" * 100)
p h.slice((n += 1; t), (t.replace("r" * 4000); t = +"z"; GC.start; "z")).size
p n
