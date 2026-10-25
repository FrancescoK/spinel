$gstr = "a"
$gpoly = [1, 2]
$grange = ("a".."e")
$gobj = Object.new

CSTR = "b"
CPOLY = [3, 4]
CRANGE = ("f".."j")
COBJ = Object.new

class Foo
  @@cstr = "c"
  @@cpoly = [5, 6]
  @@crange = ("k".."o")
  @@cobj = Object.new

  def initialize
    @istr = "d"
    @ipoly = [7, 8]
    @irange = ("p".."t")
    @iobj = Object.new
  end

  def show
    [@istr, @ipoly, @irange, @iobj.class, @@cstr, @@cpoly, @@crange, @@cobj.class]
  end
end

foo = Foo.new
p foo.show
p [$gstr, $gpoly, $grange, $gobj.class, CSTR, CPOLY, CRANGE, COBJ.class]
GC.start
p foo.show
p "survived gc"
