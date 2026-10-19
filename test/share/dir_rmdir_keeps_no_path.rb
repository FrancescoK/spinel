# Dir.rmdir, and its unlink and delete, read the path they are handed and
# keep none of it, as Dir.mkdir does. With no share row for them, the path
# joined what the walk does not follow, and so did each String it met:
# tmpdir's cleanup hands its path to FileUtils.remove_entry, which ends in
# Dir.rmdir, and Dir.mktmpdir answers that path. Once a String changed in
# place met what the walk does not follow as well (here through a proc; in
# a program that requires openssl, its write buffer), mktmpdir's answer was
# a shared String, and `dir = Dir.mktmpdir("Achasan")` was refused.
require "tmpdir"

notes = String.new
hooks = [proc { |s| s << " Station" }]
notes << "Jayang"
hooks.each { |h| h.call(notes) }

a = Dir.mktmpdir("Achasan")
b = Dir.mktmpdir("Kondae")
c = Dir.mktmpdir
p [a, b, c].map { |d| File.directory?(d) }
p File.basename(a).start_with?("Achasan")
Dir.rmdir(a)
Dir.unlink(b)
Dir.delete(c)
p [a, b, c].map { |d| File.directory?(d) }
p notes
