# Flag-only: without the flag (as on master) this program is refused.
# Block parameters, String containers and tap hold the shared handle: a
# change through any of them shows in every other name.
arr = [+"a", +"b"]
arr.each { |x| x << "!" }
p arr
s = +"s"
[s, +"t"].each { |x| x << "?" }
p s
h = { k: +"v" }
h.each_value { |x| x << "1" }
p h
u = +"u"
u.tap { |x| x << "3" }
p u
r = +"r"
list = [r, +"z"]
list[0] << "5"
p r, list
