# `x = <a String or nil> or abort "..."` (and `exit`, and `||`): the right side
# never returns, and in the C conditional it is typed as the left's nil. It
# compiled to a pointer/integer mismatch in the conditional before.
def pick(list, h) = list.include?(h) ? h : list.find { |x| x.include?(h) }

hosts = ["aurora.example.com", "vm-two.example.com"]
t = pick(hosts, "aurora") or abort "unknown host"
puts t
u = pick(hosts, "two") or exit 1
puts u
v = pick(hosts, "vm-two.example.com") || abort("no such host")
puts v
w = pick(hosts, "nowhere") || "fallback"
puts w
