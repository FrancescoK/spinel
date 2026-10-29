# `$g ||= []` types the global as `$g = []` does. Left to its UNKNOWN value,
# a global first assigned nil stayed nil-typed while its boxed slot held the
# array it was pushed to, and `($g || []).each { }` was typed from the
# literal alone: the typed dispatch assigned another class's `each` answer
# (a StringIO, reached through a boxed receiver elsewhere) into the array
# slot, and the C did not build.
require "stringio"

$stores = nil

def init_stores
  ($stores || []).each(&:call)
end

init_stores
$stores ||= []
$stores << -> { puts "store one" }
$stores << -> { puts "store two" }
init_stores
p $stores.size

pr = proc { |l| print "> ", l }
ios = [StringIO.new("c\nd\n"), [1, 2]]
ios.each { |io| io.each(&pr) }
puts
