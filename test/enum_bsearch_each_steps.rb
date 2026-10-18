# each on the Enumerator Array#bsearch answers without a block: the block
# is called for the elements the search visits, in CRuby's order, and a
# true answer, a number's sign or a zero leads it on as CRuby's
# rb_ary_bsearch_index does. As a statement the walk called the block for
# every element, and its value form searched in another order.

$seen = []
def visit(w, r)
  $seen << w
  r
end

e = [1, 2, 3].bsearch
e.each { |w| visit(w, w >= 2) }
p $seen

$seen = []
f = [1, 3, 5, 7, 9, 11].bsearch
f.each { |w| visit(w, w >= 8) }
p $seen

$seen = []
g = [1, 2, 3, 4].bsearch
g.each { |w| visit(w, 2 <=> w) }
p $seen

$seen = []
h = [1, 2].bsearch
h.each { |w| visit(w, nil) }
p $seen

$seen = []
k = [0.5, 1.5, 2.5].bsearch
k.each { |w| visit(w, 1.5 - w) }
p $seen

[].bsearch.each { |w| p w }

$seen = []
v = [1, 3, 5, 7, 9, 11].bsearch
r = v.each { |w| visit(w, w >= 8) }
p r, $seen

$seen = []
v2 = [1, 2, 3, 4].bsearch
r2 = v2.each { |w| visit(w, 2 <=> w) }
p r2, $seen

begin
  t = [1, 2].bsearch
  t.each { |w| "x" }
rescue TypeError => ex
  puts ex.message
end

# a mixed answer: the element at low once one was true, as CRuby's
$seen = []
mx = [1, 2, 3, 4, 5, 6, 7].bsearch
r3 = mx.each { |w| visit(w, [true, 1, -1][w % 3]) }
p r3, $seen
$seen = []
mx.each { |w| visit(w, [true, 1, -1][w % 3]) }
p $seen
