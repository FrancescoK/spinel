# spinel: share
# spinel: gc-minor
# An operation on a nil where an Array of shared Strings is expected runs its
# arguments before it raises NoMethodError, as CRuby does: an effect of an
# argument is seen on the nil as on an Array.
def mk(f)
  t = +"t"
  a = [t]
  t << "!"
  f ? a : nil
end

$log = []

def eff(n)
  $log << n
  n
end

def report
  p $log
  $log.clear
end

r2 = mk(true)
r2 << (eff(1); +"y")
n2 = mk(false)
p r2, n2
begin
  n2 << (eff(1); +"y")
rescue NoMethodError
  puts "nme"
end
report

r3 = mk(true)
r3.push(+"a", (eff(2); +"y"))
n3 = mk(false)
p r3, n3
begin
  n3.push(+"a", (eff(2); +"y"))
rescue NoMethodError
  puts "nme"
end
report

r4 = mk(true)
r4[0] = (eff(3); +"y")
n4 = mk(false)
p r4, n4
begin
  n4[0] = (eff(3); +"y")
rescue NoMethodError
  puts "nme"
end
report

r6 = mk(true)
r6.join((eff(6); ","))
n6 = mk(false)
p r6, n6
begin
  n6.join((eff(6); ","))
rescue NoMethodError
  puts "nme"
end
report

# a statement
r7 = mk(true)
r7 << (eff(9); +"s")
n7 = mk(false)
p r7, n7
begin
  n7 << (eff(9); +"s")
rescue NoMethodError
  puts "nme"
end
report

# an argument that reassigns the receiver's variable, a local:
# the call is made and tested on the Array Ruby read first
j1 = mk(true)
p j1.join((j1 = nil; +","))
j2 = mk(false)
begin
  p j2.join((j2 = mk(true); +","))
rescue NoMethodError
  puts "nme"
end
