# Shop::Comparable is a new class, not the builtin module: a class named
# after a builtin module inside another namespace is a class of its own.
module Shop
  class Comparable
  end
end

puts Shop::Comparable.class
