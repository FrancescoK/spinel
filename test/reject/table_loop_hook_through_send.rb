# An inherited hook defined through a send of define_singleton_method:
# CRuby calls it from Class.new while the new class has no name yet. The
# send's literal target is read as the definer it names, so the loop stays
# as written, which Spinel refuses.
module M
  class Base
    send(:define_singleton_method, :inherited) { |k| puts "inherited #{k.name.inspect}"; super(k) }
  end
  T = { 1 => "One" }
  T.each { |c, n| const_set(n, Class.new(Base)) }
end
p M::One.superclass
