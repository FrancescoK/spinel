# Dir[*patterns] and Dir.glob(*patterns) union the matches of every
# pattern the splat holds, as Dir[a, b] does. A splat whose length only
# the run time knows reached the one-pattern glob as an array and did not
# compile; one of a known length passed two patterns, which raised
# NoMethodError.

require "tmpdir"

class Watcher
  def initialize(globs) = @globs = globs
  def watched = @globs ? Dir[*@globs].map { |f| File.basename(f) }.sort : []
  def globbed = Dir.glob(*@globs).map { |f| File.basename(f) }.sort
end

Dir.mktmpdir do |d|
  %w[a.rb b.rb c.txt d.md].each { |n| File.write(File.join(d, n), "") }
  p Watcher.new([File.join(d, "*.rb"), File.join(d, "*.md")]).watched
  p Watcher.new(nil).watched
  p Watcher.new([File.join(d, "*.txt")]).globbed
  p Watcher.new(File.join(d, "c.*")).globbed
  p Dir[File.join(d, "*.rb"), File.join(d, "*.txt")].map { |f| File.basename(f) }.sort
  p Dir[*[File.join(d, "a.*"), File.join(d, "d.*")]].map { |f| File.basename(f) }.sort
end
