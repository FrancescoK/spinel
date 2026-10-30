# A hook's class_eval text runs where the include runs the hook, so a call
# in it before the includer defines its method raises CRuby's NameError;
# the statements after it do not run. The sidecar holds the error line as
# Spinel prints it.
module M
  def self.included(base) = base.class_eval { class_eval "X = zz" }
end

puts "before"
class U
  include M
  def self.zz = 5
end
puts "not reached"
