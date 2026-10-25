# A boxed value that may be a String or a Symbol, beside a user class with
# its own count, answers count as CRuby does: String#count needs the
# characters to count (ArgumentError), and a Symbol has no count
# (NoMethodError). Spinel answered the length for both. size and length
# still answer the length.

class Foo
  def count = "foo count"
  def size = "foo size"
end

[Foo.new, "hello", :sym, [1, 2, 3], {a: 1}].each do |x|
  begin
    p x.count
  rescue ArgumentError, NoMethodError => e
    p e.class
  end
  p x.size
end

y = [Foo.new, "hello"][ARGV.size + 1]
p((y.count rescue $!.class))
p y.length
