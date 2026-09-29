# A local holding a regex literal is resolved to that literal by the
# compiled-pattern table -- but only within its own scope. The resolver
# matched by NAME across the whole program, so a method's `re` parameter
# took the top-level `re = /x/` literal and scanned with the wrong pattern.
re = /x/
def strip_l(w, re) = w.sub(re, "_")
def count_l(w, re) = w.scan(re).size
p strip_l("hello", /l/), count_l("hello", /l/), "axb".sub(re, "_")
def swap(w, re, other) = w.gsub(re, other)
p swap("banana", /a/, "o"), swap("axbxc", re, "y")
