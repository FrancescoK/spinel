# File.delete and File.unlink with a lone splat delete every file in the
# Array and answer how many, as with the paths written out.
fs = (1..3).map { |i| "/tmp/spinel_del_splat_#{Process.pid}_#{i}" }
fs.each { |f| File.write(f, "x") }
p File.delete(*fs)
p fs.map { |f| File.exist?(f) }
gs = fs.first(2)
gs.each { |f| File.write(f, "y") }
p File.unlink(*gs)
p gs.any? { |f| File.exist?(f) }
File.write(fs[0], "z")
begin
  File.delete(*[fs[0], fs[1]])
rescue SystemCallError => e
  p e.class
end
p File.exist?(fs[0])
# a missing file in the middle: the one before it is deleted, then it raises
hs = (1..3).map { |i| "/tmp/spinel_del_splat_#{Process.pid}_h#{i}" }
File.write(hs[0], "a")
File.write(hs[2], "c")
begin
  File.delete(*hs)
rescue SystemCallError => e
  p e.class
end
p hs.map { |f| File.exist?(f) }
File.delete(hs[2])
# another File method keeps its splat as before
parts = %w[a b c]
p File.join(*parts)
