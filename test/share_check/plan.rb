# The String plan (#8328) against the C at each kind of site. The plan says
# whether a value is handed over as its handle, wrapped into a new one, or
# has no conversion that keeps the object (refuse), and the report counts
# where the C does the same. The appends in Page#tag are emitted under the
# views the append chain opens over its links, so their plan is computed
# live: each answers its receiver, whose handle the plan hands on, as the
# C does. The block given to at_exit boxes the bytes of a String another
# name changes: the plan refuses it, and the C copies it.
class Page
  attr_reader :out
  def initialize = @out = +""
  def tag(name, text) = (@out << "<" << name << ">" << text)
end
pg = Page.new
keep = pg.out
pg.tag("a", "b")
p keep, pg.out.equal?(keep)

s = +"abc"
at_exit { p s }
t = s
t << "!"
