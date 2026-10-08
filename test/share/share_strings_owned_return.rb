# A method can hand over its own local String on one path and return the
# caller's buffer on another. Only the former clears the return handle.
def local_or_buffer(buf = nil)
  text = +"made"
  return text unless buf
  buf.replace(text)
  buf
end
buf = +"old"
kept = buf
r = local_or_buffer(buf)
r << "!"
p [kept, r]
r = local_or_buffer rescue nil
r << "?"
p [kept, r]

# A local which aliases an outer holder is borrowed, even when returned
# beside a method-owned local. It must never be summarized as fresh.
$outer = +"outer"
def local_or_outer(which)
  local = which ? +"local" : $outer
  local
end
r = local_or_outer(false)
r << "+"
p $outer
r = local_or_outer(true)
r << "-"
p [r, $outer]

require "stringio"
buf = +"buffer"
r = StringIO.new("abc").readpartial(2, buf)
r << "+"
p [buf, r]
r = StringIO.new("xy").sysread(1, buf)
r << "!"
p buf
r = StringIO.new("qr").read_nonblock(1, buf)
r << "?"
p buf
r = StringIO.new("fresh").readpartial(2) rescue nil
r << "!"
p r
