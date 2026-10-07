# Flag-only: the default build refuses these ("a String a boxed local holds
# is stored into a container and mutated in place through it"). Under the
# flag the stored read lifts the local's String into the handle, written
# back into the local and carried to the names it was copied from or to,
# so a change through the element reaches the local and its other names,
# whichever was written first and whatever the local was written from (a
# literal's element, a block parameter). (tools/spin.rb's
# `cmd_build(prj, [target], "")` is this shape.)
def grow(list) = list.each { |e| e << "!" }
t = ARGV.empty? ? +"x" : 1
u = t
grow([t])
p t, u
v = ARGV.empty? ? +"y" : nil
w = v
[v].each { |e| e.upcase! }
p v, w
# stored, then aliased, then mutated
names = []
q = [+"zz", 1][0]
names << q
q2 = q
q << "_y"
p q2, names
# aliased before the store
r = [+"rr", 1][0]
r2 = r
list = [r]
r << "!"
p r2, list
# mutated through the element
s = [+"ss", 1][0]
cont = [s]
cont[0] << "?"
p s, cont
# written from another box
args = [+"a1", +"a2"]
t = ""
args.each { |a| t = a if t == "" }
holder = [t]
holder[0] << "#"
p t, args, holder
