# A registration whose file does not define its constant: defined? answers
# "constant" while the registration is pending, also as a guard and through
# a scope, and nil once the file has run.
autoload :UnsetTop, File.join(__dir__, "autoload_defined_unset_lib")
class UnsetScope
  autoload :Leaf, File.join(__dir__, "autoload_defined_unset_leaf_lib")
end
p defined?(UnsetTop)
puts "guarded" if defined?(UnsetTop)
p defined?(UnsetTop) ? 1 : 2
p defined?(UnsetScope::Leaf)
class UnsetScope
  p defined?(Leaf)
end
begin
  UnsetTop
rescue NameError => e
  p e.message
end
p defined?(UnsetTop)
p defined?(UnsetScope::Leaf)
begin
  UnsetScope::Leaf
rescue NameError => e
  p e.message
end
p defined?(UnsetScope::Leaf)
