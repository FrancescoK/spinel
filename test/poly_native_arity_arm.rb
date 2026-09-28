# A zero-argument poly call beside a native binding of the same name that
# takes arguments (StringScanner#peek(len)) calls the user methods, and a
# StringScanner receiver raises ArgumentError as in CRuby (#5359, Crass).
require "strscan"
class T; def peek; "t"; end; end
def f(x) = x.peek
p f(T.new)
begin
  p f([StringScanner.new("ab"), 1][0])
rescue ArgumentError, NoMethodError => e
  p e.class
end
s = StringScanner.new("xy")
p [s, T.new].map { |o| o.respond_to?(:peek) }
class U; def peek = "u"; end
p [T.new, U.new].map { |o| f(o) }
p StringScanner.new("ab").peek(1)
