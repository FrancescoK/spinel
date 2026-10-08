# CRuby refuses to load this: "Comparable is not a class (TypeError)".
# `::Comparable` inside a module still names the builtin module. Spinel
# refuses every class named after a builtin module outside the top level.
# spinel: reject-builtin-module: collides with the builtin module
module Shop
  class ::Comparable
  end
end

puts Comparable.class
