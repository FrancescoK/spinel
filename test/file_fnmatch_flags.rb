# File.fnmatch follows CRuby's matcher and honors its flags: with none a
# wildcard crosses "/" and only a leading period of the whole string is
# held back; FNM_PATHNAME works per component and lets "**/" span
# directories; FNM_DOTMATCH, FNM_NOESCAPE, FNM_CASEFOLD (ASCII, as CRuby)
# and FNM_EXTGLOB (braces) each change what they say.
require "tmpdir"

cases = [
  ["cat", "cat"], ["cat", "category"], ["c{at,ub}s", "cats"], ["c?t", "cat"], ["c??t", "cat"],
  ["c*", "cats"], ["c*t", "c/a/b/t"], ["ca[a-z]", "cat"], ["ca[^t]", "cat"], ["ca[!t]", "cab"],
  ["*", ".profile"], [".*", ".profile"], ["*", "dave/.profile"], ["**/*", "a/.b"],
  ["*", "a/b"], ["**/foo", "a/b/c/foo"], ["**/foo", "/a/b/c/foo"], ["**/foo", "c:/a/b/c/foo"],
  ["**/foo", "a/.b/c/foo"], ["*/*", "a/b"], ["a/*", "a/.b"], ["\\*", "*"], ["\\*", "a"],
  ["\\a", "a"], ["\\a", "\\a"], ["[\\]]", "]"], ["[a-c]x", "Bx"], ["CAT", "cat"],
  ["é?", "éa"], ["?", "é"], ["[à-ü]", "é"], ["a*b*c", "aXbYc"], ["a*b*c", "aXbY"],
  ["*.rb", "lib/x.rb"], ["lib/*.rb", "lib/x.rb"], ["/abs/*", "/abs/x"], ["**/", "a/"],
  ["{a,b}", "a"], ["{a,b}", "{a,b}"], ["x{a,{b,c}}y", "xcy"], ["**/*.rb", "x.rb"], ["**/*.rb", "a/b/x.rb"],
  ["a/**/b", "a/b"], ["a/**/b", "a/x/y/b"], ["a/**/b", "a/.x/b"], ["[]", "]"], ["[", "["], ["a[", "a["],
]
flagsets = [0, File::FNM_PATHNAME, File::FNM_DOTMATCH, File::FNM_PATHNAME | File::FNM_DOTMATCH,
            File::FNM_NOESCAPE, File::FNM_CASEFOLD, File::FNM_EXTGLOB, File::FNM_PATHNAME | File::FNM_EXTGLOB]
cases.each do |pat, path|
  row = flagsets.map { |f| File.fnmatch(pat, path, f) ? "T" : "." }.join
  puts "#{pat.ljust(14)} #{path.ljust(14)} #{row}"
end
p [File::FNM_NOESCAPE, File::FNM_PATHNAME, File::FNM_DOTMATCH, File::FNM_CASEFOLD, File::FNM_EXTGLOB, File::FNM_SYSCASE, File::FNM_SHORTNAME]
p File.fnmatch?("*.rb", "a/b.rb"), File.fnmatch?("*.rb", "a/b.rb", File::FNM_PATHNAME)
only = File::FNM_PATHNAME
p File.fnmatch?("/x/test", "/x/test", only)

# A range takes its own endpoints whatever their order
p File.fnmatch("[z-a]", "z"), File.fnmatch("[a-\\]]", "]")
# Braces nest to any depth, an unclosed one never matches, and FNM_NOESCAPE
# keeps a backslash from escaping a brace or a comma
x = File::FNM_EXTGLOB
p File.fnmatch("{a,b}" * 10, "a" * 10, x), File.fnmatch("{a", "{a", x)
p File.fnmatch("{a,b\\}", "b\\", x | File::FNM_NOESCAPE), File.fnmatch("{a\\,b}", "a\\,b", x | File::FNM_NOESCAPE)

# Under FNM_CASEFOLD a class's lone members fold as CRuby folds them (against
# the member after them); ranges fold both ends
cf = File::FNM_CASEFOLD
p [["[a]", "A"], ["[ab]", "A"], ["[ab]", "B"], ["[!a]", "A"], ["[a-z]", "A"], ["[A-Z]", "a"]].map { |pt, s| File.fnmatch(pt, s, cf) }
# An invalid byte is one character; a range cannot place it
p File.fnmatch("??", "\xC0\x80"), File.fnmatch("[a]", "\xff")
begin
  File.fnmatch("[a-z]", "\xe3")
rescue ArgumentError => e
  p e.class
end

# Dir.glob matches each component by the same rules: "?" takes a multibyte
# character whole, and a class can name one
root = File.join(Dir.tmpdir, "sp_fnmatch_flags_#{Process.pid}")
Dir.mkdir(root)
%w[é z B .h].each { |n| File.write("#{root}/#{n}", "") }
Dir.chdir(root) do
  p Dir.glob("?").sort.map(&:bytesize), Dir.glob("[à-ü]").map(&:bytesize)
  p Dir.glob("*", File::FNM_DOTMATCH).sort.size
end
%w[é z B .h].each { |n| File.delete("#{root}/#{n}") }
Dir.rmdir(root)
