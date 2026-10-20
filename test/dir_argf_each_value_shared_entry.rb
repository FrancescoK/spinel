# A Dir's or ARGF's loop whose value is kept, in a program that changes a
# String in place through a proc: each entry or line is the shared handle
# the rule makes it. Every pass over the loop typed the parameter a String
# again and the rule made it the handle again, so the compile never
# finished.
require "tmpdir"

stamp = proc { |s| s << " Station" }
line = String.new
line << "Jayang"
stamp.call(line)
p line

Dir.mktmpdir do |root|
  %w[seongsu kondae achasan].each { |n| File.write(File.join(root, n), "") }

  d = Dir.new(root)
  seen = []
  x = d.each { |e| seen << e }
  p x.equal?(d)
  p seen.sort
  d.close

  d = Dir.new(root)
  stops = []
  y = d.each_child { |e| stops << e; stamp.call(e) }
  p y.class
  p stops.sort
  d.close

  d = Dir.new(root)
  marked = []
  z = d.each_entry { |e| e << "!" unless e.start_with?("."); marked << e }
  p z.equal?(d)
  p marked.sort
  d.close

  # ARGF's lines, from a file put on ARGV
  ARGV << File.join(root, "kondae")
  File.write(ARGV[0], "Guui\nChildren's Grand Park\n")
  heard = []
  w = ARGF.each_line { |l| heard << l; l.chomp!; stamp.call(l) }
  p w.to_s
  p heard
end
