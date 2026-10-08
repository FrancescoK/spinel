# Regression: a `{ () -> void }` block whose tail expression is a void-typed
# call. Seeds lower an RBS `-> void` return to nil (TY_NIL), and `emit`
# compiles to a C `void` function (method_is_void keys on !is_scalar_ret,
# which excludes TY_NIL). The proc trampoline returns sp_int, so returning
# emit's (void) result emitted `return <void-call>;` and failed to compile.
# The proc must run the body for effect and return nil.
# spinel: rbs-seed-check
class Sink
  def emit(s)
    puts s
  end
  def around(&block)
    block.call if block
  end
  def go
    around { emit("ok") }
  end
end
Sink.new.go
