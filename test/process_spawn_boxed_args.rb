# spawn and exec take a boxed last argument as the options only when it
# holds a Hash, as CRuby does, and read a boxed shared String (an Array
# element that was appended to) as its String: the command, an argument,
# a splat's element and the last argument.

t = +"ech"; a = [t, 1]; a[0] << "o"
u = +"hel"; b = [u, 2]; b[0] << "lo"

Process.wait(spawn(a[0], b[0]))
Process.wait(spawn("echo", b[0]))
Process.wait(spawn("echo", b[0], "world"))
Process.wait(spawn("echo", *[b[0], "splat"]))

# a boxed last argument that is a String at run time is an argument
s = ARGV.size > 5 ? 1 : "boxed"
Process.wait(spawn("echo", "last", s))

# one that is a Hash at run time is the options
r, w = IO.pipe
o = ARGV.size > 5 ? 1 : {out: w}
pid = spawn("echo", "piped", o)
w.close
Process.wait(pid)
p r.read
r.close

# any other value raises CRuby's TypeError
n = ARGV.size > 5 ? "x" : 7
begin
  spawn("echo", n)
rescue TypeError => e
  p e.message
end
begin
  spawn("echo", 3, "x")
rescue TypeError => e
  p e.message
end

$stdout.flush
exec("echo", "exec", b[0])
