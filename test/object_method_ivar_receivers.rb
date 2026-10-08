# spinel: gc-minor
# Only receivers of a boxed Object setter need its ivar slot and reference layout.
require 'stringio'
class Object
  def store_note(v) = (@note = v)
  def unused_store(v) = (@unused = v)
end
Member = Struct.new(:note)
class NoteHolder
  def note = @note
end
class PointValue
  def initialize(x) = (@x = x)
  def x = @x
end
member = Member.new(8)
io = StringIO.new(+"")
io.write("ok")
holder = NoteHolder.new
holder.store_note(3)
p holder.note, member.note, io.string
sum = 0
1000.times { |i| sum += PointValue.new(i).x }
p sum
