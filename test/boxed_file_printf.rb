# printf on an IO handle read out of a container (a File, $stdout) formats
# its arguments and writes the result, as on a typed File, and answers nil;
# with no arguments it raises ArgumentError, as CRuby does.
path = "/tmp/sp_boxed_file_printf_#{Process.pid}.txt"
def fresh(path)
  h = File.open(path, "a")
  h.sync = true
  [h, 0][0]
end
File.write(path, "")

f = fresh(path)
p f.printf("%03d-%s\n", 7, "x")
p f.printf("plain\n")
a = [1, "two", 3.5]
f.printf("%d %s %.1f\n", *a)
f.printf("%s|%p|%-4s|%x\n", nil, nil, :sym, 255)
fmt = "%05.1f\n"
[2.25, 10.0].each { |v| f.printf(fmt, v) }
f.printf(*["%s-%s\n", "a", "b"])
e = (f.printf rescue $!)
p [e.class, e.message]
f.close

# the handle a call answers, held nowhere else, across an argument that
# allocates
fresh(path).printf("%s\n", "q#{("r" * 3000).clear}")
print File.read(path)

o = [$stdout, 0][0]
p o.printf("%s and %d\n", "stdout", 2)
def maybe(io, go) = go ? io.printf("%s\n", "went") : "skip"
p maybe(o, false)
p maybe(o, true)
quiet = false
p((quiet && o.printf("loud\n")) || :quiet)

# a receiver that is no IO raises after its arguments are evaluated
x = [5, "s"][0]
e = (x.printf("%d\n", (puts "argument"; 1)) rescue $!)
p e.class
File.delete(path)
