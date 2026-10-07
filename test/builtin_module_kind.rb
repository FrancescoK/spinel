# The builtin modules are modules: Math, Process and GC answer Module to
# #class (Math was missing from the list, Process and GC have no class id),
# and a missing method on one names it as a module.
p Math.class, Kernel.class, Comparable.class, Enumerable.class, Process.class, GC.class, Signal.class
p Math.is_a?(Class), Math.instance_of?(Module), Math.is_a?(Module), Process.is_a?(Class)
p String.class, Dir.class
[-> { Math.foo }, -> { Kernel.foo }, -> { Comparable.foo }, -> { Enumerable.new },
 -> { Math.new }, -> { Process.new }, -> { Dir.foo }, -> { String.foo }].each do |l|
  l.call
rescue NoMethodError => e
  puts e.message
end
module M; end
begin
  M.new
rescue NoMethodError => e
  puts e.message
end
x = [Math, 1][0]
begin
  x.foo
rescue NoMethodError => e
  puts e.message
end
p x.class
