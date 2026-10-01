# A SystemCallError or an Errno:: exception the program builds or raises
# carries the errno text CRuby gives it, then " - msg" for a message, and
# SystemCallError.new(msg, errno) is the Errno:: class of that number
p Errno::ENOENT.new.message
p Errno::ENOENT.new("x").message
p Errno::EACCES.new.message
p Errno::ENOENT.new.errno
e = Errno::ENOENT.new
p e.class, e.is_a?(SystemCallError), e.is_a?(StandardError)
p Errno::ENOENT.new.to_s
p Errno::ENOENT.new(nil).message
p Errno::ENOENT.new("").message
p SystemCallError.new("x").message
p SystemCallError.new("x", 2).message
p SystemCallError.new("x", 2).class
p SystemCallError.new(nil, 13).message
p SystemCallError.new(nil, 13).errno
begin; raise Errno::EACCES; rescue => x; p x.message; end
begin; raise Errno::EACCES, "f"; rescue => x; p x.message; end
begin; raise Errno::EACCES, nil; rescue => x; p x.message; end
begin; raise Errno::EACCES.new("g"); rescue => x; p x.message, x.errno; end
begin; raise SystemCallError, "h"; rescue SystemCallError => x; p x.message; end
p Errno::ENOENT::Errno
p IOError.new.message, IOError.new("m").message
