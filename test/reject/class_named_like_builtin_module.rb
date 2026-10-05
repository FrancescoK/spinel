# CRuby runs this: Shop::Comparable is a new class, not the builtin module.
# Spinel refuses every class named after a builtin module outside the top
# level, because it cannot always tell this form from `class ::Comparable`.
module Shop
  class Comparable
  end
end

puts Shop::Comparable.class
