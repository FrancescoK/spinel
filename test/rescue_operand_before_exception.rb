# `rescue operand, Exception`: Exception only ends the list, so an operand
# before it is still checked in order. A nil or an Integer is a TypeError, a
# call runs, and a splat is matched against its members. A constant that names
# a class or module before Exception, and anything after it, change nothing;
# a constant that the program defines as no class (`XN = nil`) is read in its
# place like any other operand: a TypeError. A library's class is matched by
# its name.
require "socket"
def probe(label, operand)
  begin
    raise ArgumentError, "a"
  rescue operand, Exception
    p [label, :caught]
  end
rescue TypeError => e
  p [label, :type_error, e.message]
end
probe(:nil, nil)
probe(:int, 1)
probe(:cls, KeyError)
probe(:mod, Comparable)

def side
  puts "side evaluated"
  KeyError
end
begin
  raise ArgumentError, "b"
rescue side, Exception
  p :caught2
end

begin
  raise ArgumentError, "c"
rescue Exception, nil
  p :caught3
end

list = [nil]
begin
  begin
    raise ArgumentError, "d"
  rescue *list, Exception
    p :caught4
  end
rescue TypeError => e
  p [:splat, :type_error]
end

begin
  raise IOError, "e"
rescue *[KeyError], Exception
  p :caught5
end

begin
  raise SystemExit
rescue KeyError, Errno::ENOENT, Exception => e
  p [:caught6, e.class]
end

# a clause that does not catch lets the error reach the next one
begin
  begin
    raise ArgumentError, "f"
  rescue KeyError, nil, Exception
    p :unreached
  end
rescue TypeError
  p :next_clause
end

# constants: class and module names match by name, value constants are checked
XN = nil
XI = 5
XA = ArgumentError
module Mo; end
class MyErr < StandardError; end
def t(label)
  yield
rescue TypeError => e
  p [label, :type_error, e.message]
rescue NameError => e
  p [label, :name_error, e.message]
end
t(:nil_const) { begin; raise ArgumentError, "a"; rescue XN, Exception => e; p [:nil_const, :caught, e.class]; end }
t(:int_const) { begin; raise ArgumentError, "a"; rescue XI, Exception => e; p [:int_const, :caught, e.class]; end }
t(:alias) { begin; raise ArgumentError, "a"; rescue XA, Exception => e; p [:alias, :caught, e.class]; end }
t(:module) { begin; raise ArgumentError, "a"; rescue Mo, Exception => e; p [:module, :caught, e.class]; end }
t(:user) { begin; raise MyErr, "a"; rescue KeyError, Exception => e; p [:user, :caught, e.class]; end }
t(:path) { begin; raise ArgumentError, "a"; rescue Comparable, ::Exception => e; p [:path, :caught, e.class]; end }

# a value constant alone, and an alias that is the class raised
t(:nil_alone) { begin; raise ArgumentError, "a"; rescue XN => e; p [:nil_alone, :caught, e.class]; end }
t(:alias_alone) { begin; raise ArgumentError, "a"; rescue XA => e; p [:alias_alone, :caught, e.class]; end }
t(:alias_other) { begin; raise KeyError, "a"; rescue XA => e; p [:alias_other, :caught, e.class]; rescue KeyError; p :key_error; end }

# constant paths: one that names a class matches by name, one that is a value is checked
module Config
  NONE = nil
  LIMIT = 3
  class Fail < StandardError; end
end
t(:path_nil) { begin; raise ArgumentError, "a"; rescue Config::NONE, Exception => e; p [:path_nil, :caught, e.class]; end }
t(:path_nil_alone) { begin; raise ArgumentError, "a"; rescue Config::NONE => e; p [:path_nil_alone, :caught, e.class]; end }
t(:path_int) { begin; raise ArgumentError, "a"; rescue Config::LIMIT, Exception => e; p [:path_int, :caught, e.class]; end }
t(:path_class) { begin; raise Config::Fail, "a"; rescue Config::Fail, Exception => e; p [:path_class, :caught, e.class]; end }
t(:path_class_other) { begin; raise ArgumentError, "a"; rescue Config::Fail => e; p [:path_class_other, :caught, e.class]; rescue ArgumentError; p :argument_error; end }

# names of the runtime and of libraries keep matching by name
t(:socket_error) { begin; raise ArgumentError, "a"; rescue SocketError, Exception => e; p [:socket_error, :caught, e.class]; end }
t(:socket_error_raised) { begin; raise SocketError, "a"; rescue SocketError => e; p [:socket_error_raised, :caught, e.class]; end }
t(:errno) { begin; raise ArgumentError, "a"; rescue Errno, Exception => e; p [:errno, :caught, e.class]; end }
t(:marshal) { begin; raise ArgumentError, "a"; rescue Marshal, Exception => e; p [:marshal, :caught, e.class]; end }
