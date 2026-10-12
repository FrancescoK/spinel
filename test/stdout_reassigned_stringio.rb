# `$stdout = StringIO.new` captures what the bare output calls print, as
# minitest's capture_io / assert_output rely on. Kernel#puts is
# `$stdout.puts`, and print, p and printf write through `$stdout` too; they
# wrote to the C stream directly, so the swap was silently ignored and the
# capture came back empty. warn and `$stderr.puts` follow a swapped $stderr
# the same way.
require "stringio"
require "tmpdir"

def capture_io
  out, err = StringIO.new, StringIO.new
  orig_out, orig_err = $stdout, $stderr
  $stdout, $stderr = out, err
  yield
  return out.string, err.string
ensure
  $stdout = orig_out
  $stderr = orig_err
end

class Pt
  def initialize(x) = @x = x
  def inspect = "#<Pt #{@x}>"
end

class Reporter
  def report(n) = print("ran ", n, "\n")
end

out, err = capture_io do
  puts "a", 1, nil, [2, [3]]
  puts
  puts [], "z"
  print "b", 4, "\n"
  p "q"
  x = p(Pt.new(5))
  y = p(6, :sym)
  [7, 8].each { |v| p v }
  printf("%05.1f|%s\n", 3.14159, :fmt)
  Reporter.new.report(9)
  $stdout.puts "c"
  $stdout.print "d\n"
  $stdout.write("e\n")
  puts x.inspect, y.inspect
  warn "w1"
  warn "w2\n", ["w3", ["w4"]]
  $stderr.puts "e1"
  $stderr.print "e2\n"
end
p out
p err

# restored: back on the real streams
puts "after"
p [1, 2]

# a File in $stdout takes the bare calls too
path = File.join(Dir.tmpdir, "spinel_stdout_reassigned_#{Process.pid}.txt")
f = File.open(path, "w")
$stdout = f
puts "to file", []
p :file
$stdout = STDOUT
f.close
p File.read(path)
File.delete(path)
