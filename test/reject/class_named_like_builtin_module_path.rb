# CRuby runs this: Foo::Comparable is a new class, and the builtin
# Comparable stays a module. Spinel made the builtin a class, so it refuses
# every class named after a builtin module outside the top level.
class Foo
end

class Foo::Comparable
end

puts Comparable.class
