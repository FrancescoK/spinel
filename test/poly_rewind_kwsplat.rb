# `rewind(**opts)` on a receiver whose class is known only at run time: a
# poly receiver's rewind is typed as a box (an Enumerator answers itself, a
# stream its 0), and the zero-argument arm boxes the stream's 0 for it. A
# forwarded `**` (Active Support's Object#try hands every call on with
# `*args, **kwargs, &block`) reached the stream arm that takes the splat,
# which stored the bare sp_int into the box, and the C did not build.
require "stringio"

class Cursor
  def initialize = @pos = 3
  def rewind
    @pos = 0
    self
  end
  def pos = @pos
end

def rewind_of(v, **opts) = v.rewind(**opts)

io = StringIO.new("hello")
io.read
f = File.open(__FILE__)
f.gets
cur = Cursor.new

[cur, io, f].each do |v|
  r = rewind_of(v)
  p r.class
  p r.equal?(v)
end
p io.pos
p cur.pos
p f.gets[0, 19]
f.close

