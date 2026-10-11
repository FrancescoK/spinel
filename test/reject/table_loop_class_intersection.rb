# `[a-c&&b]` is the intersection of two classes (only b) in Ruby's regexps.
# The compile-time gsub reads one plain class only, so the loop stays as
# written, which Spinel refuses.
module M
  class Base; end
  T = { 1 => "Oabcne" }
  T.each { |c, n| const_set(n.gsub(/[a-c&&b]/, ""), Class.new(Base)) }
end
p M.constants.sort
