# Dir.glob(pattern, base: dir) walks a relative pattern from dir and answers
# paths relative to it. The keyword went to the unresolved-method path and
# raised NoMethodError. The base is a directory name, not a pattern, so glob
# metacharacters in it match only themselves.
require "tmpdir"

Dir.mktmpdir do |root|
  dir = File.join(root, "b[1]")
  ["", "/a", "/a/x", "/.h"].each { |d| Dir.mkdir("#{dir}#{d}") }
  ["a/SKILL.md", "a/x/y.md", "top.md"].each { |f| File.write(File.join(dir, f), "") }

  p Dir.glob("*/SKILL.md", base: dir)
  p Dir.glob("**/*.md", base: dir)
  p Dir.glob("*", base: dir)
  p Dir.glob("*/", base: dir)
  p Dir.glob("a", base: dir)
  p Dir.glob("{a,top.md}", base: "#{dir}/")
  p Dir.glob("*", base: File.join(dir, "missing"))
  p Dir.glob("#{root}/*", base: File.join(dir, "a")).map { |f| f.delete_prefix(root) }
  p Dir.chdir(dir) { Dir.glob("*.md", base: nil) }
  # the same directory joined onto the pattern is read as a pattern
  p Dir.glob(File.join(dir, "*.md"))
end
