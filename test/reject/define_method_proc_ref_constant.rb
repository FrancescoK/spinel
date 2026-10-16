# spinel: reject-subclass: Module#define_method with `&` of a block or Proc that is not a literal
# The body is a Proc only the run time holds: the method was defined with no
# body and answered nil.
class FromConstant
  BODY = proc { "called" }
  define_method :from_proc, &BODY
end
p FromConstant.new.from_proc
