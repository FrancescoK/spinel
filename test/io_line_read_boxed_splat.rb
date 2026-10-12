# gets and readline on an IO reached through a boxed value, their arguments
# splatted: beside a user method of the same name the builtin default arm
# declined the splat and raised NoMethodError, and with none the boxed IO
# arm passed the list itself as the separator and the C did not build.
class Reader
  def gets(*args) = [:reader, args]
  def readline(*args) = [:reader, args]
end

# WEBrick reads request lines this way
def read_data(io, name, *args)
  io.__send__(name, *args)
end
def gets_opts(io, *args, **opts)
  io.gets(*args, **opts)
end

r, w = IO.pipe
w.write("GET / HTTP/1.1\r\nHost: x\r\nabcdef\nlast\n")
w.close
ios = [r, Reader.new]

p read_data(ios[0], :gets, "\n", 2083)
p read_data(ios[0], :readline, "\n", 4)
p read_data(ios[0], :gets, 0)
p gets_opts(ios[0], chomp: true)
p gets_opts(ios[0], "c", chomp: true)
p read_data(ios[0], :gets)
p read_data(ios[0], :gets, nil)
p read_data(ios[0], :gets)
begin
  read_data(ios[0], :readline)
rescue EOFError
  p :eof
end
p read_data(ios[1], :gets, "\n", 2083)
p read_data(ios[1], :readline)
r.close

def plain_gets(io, *args) = io.gets(*args)
def plain_readline(io, *args, **opts) = io.readline(*args, **opts)
r2, w2 = IO.pipe
w2.write("ab\ncd\nef\n")
w2.close
plain = [r2, 1]
p plain_gets(plain[0], "d")
p plain_readline(plain[0], chomp: true)
p plain_gets(plain[0])
p plain_gets(plain[0])
r2.close
