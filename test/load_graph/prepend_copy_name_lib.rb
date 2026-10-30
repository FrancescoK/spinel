class Wrapped
  def foo = "W"
  define_method(:"__prep 0 foo") { "own" }
end
