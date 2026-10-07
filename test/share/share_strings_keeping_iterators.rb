# Flag-only: an iterator that keeps the elements it yields (select, reject,
# filter_map, partition, find_all) over a String Array whose elements its
# block changes and hands on. Over a local's Array the block parameter, the
# Array, the iterator's answer and the other holder name the same Strings.
# Over a fresh Array (a scan's answer) the elements are named again by the
# answer and the other holder, so the share rule refuses it, as before the
# fresh-Array route: only a dropped `each` over one hands each String to its
# block alone.
kept = []
a = [+"a", +"b"]
s = a.select { |e| e << "1"; kept << e; true }
r = a.reject { |e| e << "2"; kept << e; e.start_with?("a") }
f = a.filter_map { |e| e << "3"; kept << e; e if e.start_with?("b") }
pt = a.partition { |e| e << "4"; kept << e; e.start_with?("a") }
fa = a.find_all { |e| e << "5"; kept << e; true }
kept[0] << "!"
s[1] << "?"
p a, s, r, f, pt, fa
p kept.size, kept[0].equal?(a[0]), fa[1].equal?(a[1])
