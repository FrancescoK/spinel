# spinel: gc-stress
# IO#readpartial with a negative length raises ArgumentError naming the
# length, before the stream is read or checked (a closed handle says the
# same), also through a value that may be an IO or an Integer.
r, w = IO.pipe
w.write("ab")
p r.readpartial(0)
[-1, -3].each do |n|
  begin
    p r.readpartial(n)
  rescue => e
    p [e.class, e.message]
  end
end
io = Process.pid > 0 ? r : 1
begin
  p io.readpartial(-2)
rescue => e
  p [e.class, e.message]
end
p r.readpartial(5)
r.close
begin
  r.readpartial(-1)
rescue => e
  p [e.class, e.message]
end
w.close
