# File#readlines given a limit, a nil, a separator and a limit, or a boxed
# argument: CRuby reads a lone nil or String as the separator and anything
# else as the limit, a limit of 0 is ArgumentError and a negative one none;
# a handle read out of a mixed Array dropped them all.
# The arm passed every argument as the separator, and each of these did not
# build.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_readlines_limit_#{Process.pid}.txt")
File.write(path, "abc\ndef\n\nxy\n")
def t(path)
  f = File.open(path)
  p yield(f)
rescue TypeError, ArgumentError => e
  p [e.class, e.message]
ensure
  f&.close
end
k = ARGV.size
lim = 2
nl = nil
sep = "e"
t(path) { |f| f.readlines(lim) }
t(path) { |f| f.readlines(nl) }
t(path) { |f| f.readlines(sep, lim) }
t(path) { |f| f.readlines(nl, 5) }
t(path) { |f| f.readlines(sep, nl) }
t(path) { |f| f.readlines(-1) }
t(path) { |f| f.readlines(0) }
t(path) { |f| f.readlines(3, chomp: true) }
t(path) { |f| f.readlines("", 4) }
bs = ["d", 1][k]
bl = [3, "x"][k]
t(path) { |f| f.readlines(bs) }
t(path) { |f| f.readlines(bl) }
t(path) { |f| f.readlines(bs, bl) }
t(path) { |f| f.readlines(:sym) }
t(path) { |f| f.readlines(1.5) }
t(path) { |f| f.readlines(lim, lim) }
t(path) { |f| f.readlines(sep, [1]) }
bf = [File.open(path), 1][k]
p bf.readlines(lim)
bf.rewind
p bf.readlines(sep, 3, chomp: true)
begin
  bf.readlines(sep, lim, lim)
rescue ArgumentError => e
  p e.message
end
bf.close
nf = k == 0 ? nil : File.open(path)
begin
  nf.readlines(lim)
rescue NoMethodError => e
  p e.message
end
File.delete(path)
