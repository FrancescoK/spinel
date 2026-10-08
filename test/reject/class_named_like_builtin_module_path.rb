# CRuby runs this: Foo::Comparable is a new class, and the builtin
# Comparable stays a module. Spinel made the builtin a class, so it refuses
# every class named after a builtin module outside the top level.
# spinel: reject-builtin-module: collides with the builtin module
class Foo
end

class Foo::Comparable
end

puts Comparable.class
