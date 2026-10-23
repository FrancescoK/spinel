# spinel: gc-stress
# Dir#dup returns a new Dir with no stream and no path, on a typed and a
# boxed receiver; the original keeps its path and still reads.
d = Dir.open(".")
begin
  copy = d.dup
  p [d.object_id == copy.object_id, copy.path, copy.class]
  begin
    copy.read
  rescue IOError => error
    p [error.class, error.message]
  end
  boxed = [d, 1][0].dup
  p [boxed.equal?(d), boxed.path]
  p copy.dup.path
  p d.path
  p d.read.nil?
ensure
  d.close
end
p d.dup.path
