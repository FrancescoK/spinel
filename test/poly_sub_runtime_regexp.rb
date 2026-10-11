# sub / gsub on a receiver typed only at run time (a method answering a String
# or an Integer) with a pattern that is no regexp literal: an interpolated
# regexp, a Regexp value, or a value that is a Regexp or a String by its tag.
# The String receiver's arms serve it; the call used to raise "undefined method
# 'gsub' for an instance of String".
BASE = /#{Regexp.escape("/src")}\//

def pick(n) = n > 0 ? "/src/a.rb:3\n/src/b.rb:9" : 42

p pick(1).gsub(BASE, "")
p pick(1).sub(BASE, "")
p pick(1).gsub(/#{"rb"}/, "py")
re = Regexp.new(":\\d+")
p pick(1).gsub(re, "")
p pick(1).sub(re, ":0")
p pick(1).gsub(BASE, "/src/" => "~/")
[BASE, "/src"].each { |pat| p pick(1).gsub(pat, "@") }

begin
  pick(0).gsub(BASE, "")
rescue NoMethodError => e
  puts e.class
end

# a user class owning the name keeps its own method
class Path
  def gsub(pat, rep) = "Path#gsub"
end
def either(n) = n > 0 ? "/src/c.rb" : Path.new
p either(1).gsub(BASE, "")
p either(0).gsub(BASE, "")
