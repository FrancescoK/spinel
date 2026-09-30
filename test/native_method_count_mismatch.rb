require "stringio"
require "strscan"

def t(label)
  r = yield
  p [label, :ok, r]
rescue ArgumentError => e
  p [label, e.message]
end

s = StringIO.new("ab\ncd\n")
t(:gets) { s.gets(nil, 1, 2) }
t(:readline) { s.readline("b", 1, 2) }
t(:getc) { s.getc(1) }
t(:seek) { s.seek(1, 2, 3) }
t(:truncate) { s.truncate(1, 2) }
p s.gets

ss = StringScanner.new("abc")
t(:scan) { ss.scan(/a/, 2) }
t(:getch) { ss.getch(1) }

# a boxed receiver holding a StringIO
v = [StringIO.new("xy"), 1][0]
t(:poly_seek) { v.seek(1, 2, 3) }
t(:poly_getc) { v.getc(1) }
t(:poly_gets) { v.gets(1, 2, 3) }

# write takes any count
w = StringIO.new
t(:write0) { w.write }
t(:write3) { w.write("ab", 1, :c) }
t(:poly_write) { [w, 1][0].write("q", 2) }
p w.string
