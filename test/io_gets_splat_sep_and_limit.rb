# IO#gets(sep, limit) reached through __send__ with its arguments in a
# splat (webrick reads request lines as `io.__send__(:gets, LF, size)`): the
# first is the separator, the second the limit, as when written out
r, w = IO.pipe
w.write("GET / HTTP/1.1\r\nHost: x\r\nAccept: */*\r\n\r\nabcdefghij\nxyz")
w.close
def rd(io, m, *a) = io.__send__(m, *a)
p rd(r, :gets, "\n", 2083)
p rd(r, :gets, "\n", 4096)
p rd(r, :gets, "\n")
p rd(r, :gets)
p rd(r, :gets, "\n", 4)
p rd(r, :gets, "\n", 100)
p rd(r, :gets, nil)
p rd(r, :gets)
