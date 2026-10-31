# The class-body macro form declines: a builtin class reopened.
class String
  def self.mk(n) = define_method(n) { 1 }
  mk :zz_one
end
p "x".zz_one
