# A String Range built at run time from Strings the program shares (changed
# in place through another name) keeps its ends as their handles. Its
# Enumerator read the bare end, which is empty then, took the Range for an
# endless one and streamed succ until memory ran out.
b = +"b"
e = +"e"
b2 = b
b2 << ""
e2 = e
e2 << ""
arr = [1, b, e]
def via_param(a) = (a[1]..a[2]).each.to_a
p via_param(arr)
def with_index(a) = (a[1]...a[2]).each_with_index.to_a
p with_index(arr)
p((arr[1]..arr[2]).each.first(2))
p((arr[1]..).each.first(3))
