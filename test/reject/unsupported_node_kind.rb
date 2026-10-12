# A flip-flop and a bare regexp literal as a condition are Prism node kinds
# spinel does not compile. The refusal names the kind and where it was
# written, not the internal node id.
def between(i)
  i if (i == 3)..(i == 5)
end

def matches(line)
  $_ = line
  1 if /fo/
end

p between(4)
p matches("foo")
