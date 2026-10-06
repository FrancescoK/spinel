# Typed Array-subclass paths that must match CRuby (#7449 follow-up):
# (page || "").empty? boxes the typed page as its Array (not as a user
# object), and plain_array != typed_page views the page as its Array
# (as == already did). Boxed paths that already worked stay covered.
class Page < Array
  def initialize(records, source)
    super(records)
    @source = source
  end
  attr_reader :source
end

page = Page.new([1, 2], :room)
p page.empty?
p (page || "").empty?
p (Page.new([], :room) || "").empty?

objs = [page]
o = objs[0]
p (o || "").empty?

a = [2, 3]
p2 = Page.new([2, 3], :room)
p a == p2
p a != p2
p p2 == a
p p2 != a
p a != Page.new([2, 4], :room)
p a != o
p o != a
