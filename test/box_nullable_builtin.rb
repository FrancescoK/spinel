# A reference-backed BUILTIN type (IO/Fiber/Thread/Exception/Proc/...) is a
# nilable C pointer just like a user object: an unset ivar or a `return nil`
# yields NULL. Boxing it into a poly slot must produce nil, not a "truthy"
# wrapper over a NULL pointer -- otherwise `x.nil?` lies and `if x` / `unless x`
# passes, then the first method/field read segfaults.
class Sink
  def open(p); @io = File.open(p, "w"); end
  def io; @io; end   # @io is a NULL sp_File* until #open runs
end

s = Sink.new
box = []
box << s.io          # boxes a NULL IO into a poly array
a = box[0]
puts "unset nil? #{a.nil?}"
puts "BUG: truthy NULL IO" if a        # without the fix, this wrongly prints

s.open("/tmp/box_nullable_builtin_out_#{Process.pid}.txt")
box << s.io          # boxes a real IO into the poly array
b = box[1]
puts "open nil? #{b.nil?}"
puts "have io" if b                     # this SHOULD print
puts "done"
