# ObjectSpace.define_finalizer: the callable runs after its object is
# collected (in registration order), with the object's id, or at exit for
# what is still alive; undefine_finalizer drops it; a finalizer's exception
# is dropped.
class R
  def initialize(n)
    @n = n
    ObjectSpace.define_finalizer(self, self.class.fin(n, object_id))
  end
  def self.fin(n, oid) = proc { |id| puts "fin #{n} #{id == oid}" }
end
3.times { |i| R.new(i) }
GC.start
keep = R.new(9)
gone = R.new(7)
ObjectSpace.undefine_finalizer(gone)
ObjectSpace.undefine_finalizer(gone)
boom = Object.new
ObjectSpace.define_finalizer(boom, proc { |_id| raise "ignored" })
begin
  ObjectSpace.define_finalizer(:sym, proc { |_id| puts "sym" })
rescue ArgumentError => e
  puts e.message
end
puts "end"
