# A String method called on an and/or whose left is a String the program
# holds as its handle (an element, ARGV's) read the chain's handle where
# it takes the bytes: `(ARGV[0] || "16").to_i`, the benchmarks' argument
# idiom, failed to compile.
n = (ARGV[0] || "16").to_i
p n
p (ARGV[0] || "abc").size
a = [+"5", +"xyz"]
p (a[0] || "18").to_i
p (a[1] || "19").length
p (a[3] || "twenty").bytesize
p (a[1] && "21").to_i
p (a[0] || "q").upcase
s = a[0] || "d"
s << "!"
p a[0]
