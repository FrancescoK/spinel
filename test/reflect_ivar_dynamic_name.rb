# A reflection-created slot beside an instance_variable_set whose name is
# known only at run time: the compiler's scan of reflective writes skips the
# run-time name instead of reading it.
class K; end
x = K.new
p x.instance_variable_set(:@q, nil)
p x.instance_variable_defined?(:@q)
p x.instance_variables
name = [:@r, :@s][ARGV.size]
x.instance_variable_set(name, 2) if ARGV.size > 0
p x.instance_variable_defined?(:@q)
