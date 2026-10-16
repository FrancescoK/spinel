# Foo::Comparable is a new class, and the builtin Comparable stays a
# module.
class Foo
end

class Foo::Comparable
end

puts Comparable.class
