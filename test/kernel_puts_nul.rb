# Kernel#puts and #print, and IO#<<, write a String's embedded NUL, whether the
# String is typed, an Array element or a boxed value.
a = ["x\0y"]
puts a
v = [1, "d\0e"].last
puts v
print v, "\n"
s = "plain\0str"
puts s
print s, "\n"
h = {k: "h\0i"}
puts h[:k]
puts h.values
puts [["n\0m"]]
puts [1, "p\0q"]
puts "r\0s", v
print(*[1, "t\0u", "\n"])
puts(*[v, "w\0z"])
$stdout << v << "\n"
