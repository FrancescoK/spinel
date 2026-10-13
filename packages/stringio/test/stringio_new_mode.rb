# StringIO.new(str, mode) honours the mode's first char. Only io.string
# / io.read are asserted: Spinel copies the initial string while CRuby
# operates on it by reference, so the passed-in variable diverges and is
# out of scope here. A frozen String (a literal) opened for writing is
# Errno::EACCES, and one opened for reading takes no write (IOError).
require 'stringio'

# "w" truncates the initial content to empty.
io = StringIO.new(+"existing", "w")
io.print("foo")
p io.string
p StringIO.new(+"existing", "w").string

# "a" keeps the content and seeks to the end, so writes append.
io2 = StringIO.new(+"head", "a")
io2.print("tail")
p io2.string

# "r" and the no-mode form keep the content at position 0.
io3 = StringIO.new("data", "r")
p io3.read
p StringIO.new("data").string

# a frozen String: no write mode, and no write through a read-only one
["w", "a", "r+"].each do |m|
  begin
    StringIO.new("lit", m)
  rescue SystemCallError => e
    p [m, e.class, e.message]
  end
end
begin
  StringIO.new("lit").write("x")
rescue IOError => e
  p e.message
end
