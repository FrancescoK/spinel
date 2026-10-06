# A builtin method called on an Array or a Hash an --rbs `T?` signature
# types, nil at run time, raises CRuby's NoMethodError after its arguments
# have run. The typed emission read the NULL pointer as an empty
# collection (count answered 0, transpose [], merge {}) or crashed (sort,
# rotate, except).
def nbr_ints(x) = x
def nbr_strs(x) = x
def nbr_floats(x) = x
def nbr_rows(x) = x
def nbr_counts(x) = x
def nbr_names(x) = x
def nbr_str(x) = x

def show(tag)
  r = yield
  puts "#{tag} #{r.inspect}"
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def arrays(k)
  log = []
  a = nbr_ints(k == 0 ? nil : [3, 1, 2])
  show("sort") { a.sort }
  show("rotate") { a.rotate }
  show("count") { a.count((log << :a0; 1)) }
  show("log") { log }
  show("first") { a.first(2) }
  show("join") { nbr_strs(k == 0 ? nil : ["a", "b"]).join("-") }
  show("sum") { nbr_floats(k == 0 ? nil : [1.5, 2.5]).sum }
  show("transpose") { nbr_rows(k == 0 ? nil : [[1, 2], [3, 4]]).transpose }
  show("push") { a.push(4); a }
end

def hashes(k)
  log = []
  h = nbr_counts(k == 0 ? nil : {"a" => 1, "b" => 2})
  show("except") { h.except("a") }
  show("merge") { h.merge((log << :a0; {"c" => 3})) }
  show("log") { log }
  show("keys") { h.keys }
  show("fetch") { nbr_names(k == 0 ? nil : {"a" => "x"}).fetch("a") }
  show("aset") { h["z"] = 26; h.size }
  show("str") { nbr_str(k == 0 ? nil : +"ab").to_sym }
end

arrays(0)
arrays(1)
hashes(0)
hashes(1)
