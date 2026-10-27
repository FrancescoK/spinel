# An inherited hook defined under a name held in a variable: CRuby calls it
# from Class.new while the new class has no name yet, so it prints nil. Run
# at compile time, the loop would define a named class and lose the call. A
# definer whose name the compiler can't read counts as the hook, so the
# loop stays as written, which Spinel refuses.
module M
  class Base
    hook = :inherited
    define_singleton_method(hook) { |k| puts "inherited #{k.name.inspect}"; super(k) }
  end
  T = { 1 => "One" }
  T.each { |c, n| const_set(n, Class.new(Base)) }
end
p M::One.superclass
