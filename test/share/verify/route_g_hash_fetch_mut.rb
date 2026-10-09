h = {"a" => 1}
s = +"a"
p h.fetch(s) { s << "b"; 9 }, s
