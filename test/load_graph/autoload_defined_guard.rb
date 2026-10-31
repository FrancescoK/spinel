# A defined? guard on a scoped path whose parent is autoloaded evaluates the
# parent where it stands, so the file runs there even though the leaf is
# not defined.
autoload :GuardHolder, File.join(__dir__, "autoload_defined_guard_lib")
puts "never" if defined?(GuardHolder::Nope)
puts "between"
p defined?(GuardHolder::Nope)
