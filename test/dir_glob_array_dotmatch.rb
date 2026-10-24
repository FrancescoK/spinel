# spinel: gc-stress
# Dir.glob with an Array of patterns and File::FNM_DOTMATCH globs each
# pattern with the flag; a pattern that is no String raises TypeError.
require "tmpdir"
dir = File.join(Dir.tmpdir, "spinel_glob_array_dot_#{Process.pid}")
Dir.mkdir(dir)
normal = File.join(dir, "a.md")
hidden = File.join(dir, ".hidden.md")
File.write(normal, "x")
File.write(hidden, "x")
def names(paths)
  paths.map { |path| File.basename(path) }
end
def report(tag)
  p [tag, yield]
rescue => error
  p [tag, error.class, error.message]
end
begin
  pat = File.join(dir, "*.md")
  report(:literal) { names(Dir.glob([pat], File::FNM_DOTMATCH)) }
  pats = [pat, File.join(dir, "a*")]
  report(:local) { names(Dir.glob(pats, File::FNM_DOTMATCH)) }
  report(:empty) { Dir.glob([], File::FNM_DOTMATCH) }
  boxed = [1, [pat]][1]
  report(:boxed) { names(Dir.glob(boxed, File::FNM_DOTMATCH)) }
  report(:integer) { Dir.glob([pat, 1], File::FNM_DOTMATCH) }
  report(:nil) { Dir.glob([nil], File::FNM_DOTMATCH) }
ensure
  File.delete(normal)
  File.delete(hidden)
  Dir.rmdir(dir)
end
