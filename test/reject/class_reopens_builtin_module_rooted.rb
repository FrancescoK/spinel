# CRuby refuses to load this: "Comparable is not a class (TypeError)".
# `::Comparable` inside a module still names the builtin module.
# spinel: reject-builtin-module: Comparable is not a class (TypeError)
module Shop
  class ::Comparable
  end
end

puts Comparable.class
