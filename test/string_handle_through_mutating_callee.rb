# A String reached through a reader or a container element keeps its identity
# when it is passed to a method that mutates it in place. #5112 made the ivar
# a shared handle when the mutation goes THROUGH the reader; the mutation the
# CALLEE performs on what the reader HANDED OUT stayed a copy, and the
# caller's string came back empty with no error.
#
# Each source shape gets its own helper: a plain local is lent by address (the
# byref out-param) while a reader result is a handle, and one name cannot yet
# carry both ABIs.
def push_reader(x);    x << "!"; end
def push_alias(x);     x << "!"; end
def push_getter(x);    x << "!"; end
def push_hash(x);      x << "!"; end
def push_array(x);     x << "!"; end
def push_local(x);     x << "!"; end
def push_ivar(x);      x << "!"; end

class Box
  attr_reader :reader
  def initialize; @reader = +""; end
  def getter; @reader; end
end

b = Box.new; push_reader(b.reader);            p b.reader
b = Box.new; t = b.reader; push_alias(t);      p b.reader
b = Box.new; push_getter(b.getter);            p b.reader

h = { k: +"" }; push_hash(h[:k]);              p h[:k]
a = [+""];      push_array(a[0]);              p a[0]

# the shapes that already worked: a plain local, and a bare ivar argument --
# both lvalues the caller can lend to the byref out-param
s = +"a"; push_local(s);                       p s

class Inner
  def initialize; @buf = +""; end
  def go; push_ivar(@buf); @buf; end
end
p Inner.new.go
