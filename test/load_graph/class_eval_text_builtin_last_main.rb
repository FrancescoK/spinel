# A class_eval's text is the program's code, not a builtins/ file's, also
# when the file flattened last is one (RbConfig loads builtins/rbconfig.rb
# at boot): a call in it before its method's def raises, as the body's own
# call does.
p RbConfig::CONFIG.key?("host_os")
class Ops
  class_eval "begin; A = zz(); rescue NoMethodError => e; puts e.message; end"
  def self.zz = 5
end
p Ops.zz
