# define_method(:m, &block) in a class method, with that method's own
# block: the defined method's body is the caller's block, known only at
# run time. It compiled with no parameters and raised ArgumentError (CRuby
# prints 42); refused, not answered wrongly (#9268).
class K
  def self.step(&block)
    define_method(:step_with_ctx, &block)
  end
end
K.step { |v| v * 2 }
p K.new.step_with_ctx(21)
