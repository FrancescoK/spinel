# An earlier argument runs before an autoloading constant argument also when
# the constant has no presence flag of its own (a program defining
# const_missing reads its constants unguarded): the read is bound in order.
class ArgUnrelated
  def self.const_missing(n) = 0
end
autoload :ArgValue, File.join(__dir__, "autoload_argument_effect_lib")
def arg_log(x) = (puts "log #{x}"; x)
p arg_log(1) + ArgValue
