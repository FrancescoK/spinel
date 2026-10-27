# spinel: gc-stress
# The LoadError of a computed require names a path longer than the
# runtime's 4,096-byte formatting buffer whole, in its message and as its
# path: the path, a temporary no frame roots, stays rooted while the
# runtime copies it (a copy that long allocates before it reads the path
# again, and a collection there freed it).
def load_long(n)
  require("nonexistent/" + "a" * n)
  :loaded
rescue LoadError => e
  [e.message.size, e.path.size, e.path == "nonexistent/" + "a" * n,
   e.message == "cannot load such file -- #{e.path}"]
end
p load_long(10)
p load_long(5000)
