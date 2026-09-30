# A method a `class Object` reopening defines is every object's: a bare call
# to it from inside an instance method -- activesupport's `acts_like?(:time)`
# in DateAndTime::Zones#in_time_zone, copied into Date and Time -- reaches it
# with self as the receiver, whether the method is the class's own or one a
# module copied in, and whether or not the call site is inlined. It used to
# resolve only through inlining; the method body itself raised NoMethodError.

class Object
  def tagged(x) = "tag:#{x}"
  def acts_like?(duck) = respond_to?(:"acts_like_#{duck}?")
end

module Zones
  def via_module = tagged(:m)
  def via_module_arg(d) = acts_like?(d)
end

class Note
  include Zones
  def own(x) = tagged(x)
  def own_arg = acts_like?(:note)
  def acts_like_note? = true
end

notes = [Note.new, Note.new]
notes.each { |n| p n.own(1), n.own_arg }
notes.each { |n| p n.via_module, n.via_module_arg(:note), n.via_module_arg(:cat) }
p notes.map { |n| n.own(2) }
p 5.tagged(:int), "s".acts_like?(:string)
