# CRuby refuses to load this: "Comparable is not a class (TypeError)".
# Comparable is a builtin module, so `class Comparable` cannot reopen it.
class Comparable
end

puts Comparable.class
