# Hash#to_h answers the Hash itself, so this program adds Two to the table
# before the loop runs. The table is the loop's input only while nothing
# else can reach it, so the loop stays as written, which Spinel refuses.
module M
  class Base; end
  T = { 1 => "One" }
  T.to_h[2] = "Two"
  T.each { |c, n| const_set(n, Class.new(Base)) }
end
p defined?(M::Two)
