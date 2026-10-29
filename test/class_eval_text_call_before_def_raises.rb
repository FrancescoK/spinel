# A class_eval's text runs where the eval stands, so a call in it before
# its method's def raises CRuby's NameError, as the body's own call does;
# the statements after it do not run. The sidecar holds the error line as
# Spinel prints it.
puts "before"

# a call with parentheses raises NoMethodError
class Ops
  class_eval "begin; A = zz(); rescue NoMethodError => e; puts e.message; end"
  def self.zz = 5
end

class U
  class_eval "X = zz"
  def self.zz = 5
end
puts "not reached"
