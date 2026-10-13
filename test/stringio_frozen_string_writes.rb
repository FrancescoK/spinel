# A StringIO opened on a frozen String (a literal) takes no write, `<<` or
# truncate (IOError, as CRuby run with frozen string literals), and a
# frozen String opened for writing ("w", "a", "r+") is Errno::EACCES; one
# opened on a String of its own, or opened for reading, works as before. A
# String frozen after it was opened takes none either ("not modifiable
# string"). Typed and boxed.
require "stringio"
def try(tag)
  p [tag, yield]
rescue IOError, SystemCallError => e
  p [tag, e.class, e.message]
end
lit = StringIO.new("lit")
%w[write print puts putc << truncate].each do |m|
  try(m) do
    case m
    when "write" then lit.write("x")
    when "print" then lit.print("x")
    when "puts" then lit.puts("x")
    when "putc" then lit.putc("x")
    when "<<" then lit << "x"
    else lit.truncate(1)
    end
  end
end
p lit.read, lit.string
%w[w a r+ r].each { |m| try(m) { StringIO.new("lit", m).string } }
own = StringIO.new(+"own")
own << "!"
p own.string
f = [1, StringIO.new("lit")][1]
try(:boxed) { f << "x" }
try(:boxed_write) { f.write("x") }
p f.string
s = +"x"
later = StringIO.new(s)
s.freeze
try(:frozen_since) { later.write("y") }
