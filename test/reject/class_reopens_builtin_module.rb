# CRuby refuses to load this: "Comparable is not a class (TypeError)".
# Comparable is a builtin module, so `class Comparable` cannot reopen it.
# spinel: reject-builtin-module: Comparable is not a class (TypeError)
class Comparable
end

puts Comparable.class
