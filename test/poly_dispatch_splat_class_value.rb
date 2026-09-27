# A splatted argument list into a method on a boxed receiver, where a class
# also defines a class method of that name: the class-side pre-arm (the
# arm a class VALUE in the slot takes) filled its parameters one temp each,
# so the whole call was refused. It now spreads the array the way the
# instance arms do -- activesupport's Notifications, where Fanout#publish
# forwards to each listener's `publish` and the module has its own.
module Notes
  def self.publish(name, *args) = notifier.publish(name, *args)
  def self.notifier = (@n ||= Fan.new)
end
class Sub
  def publish(name, *args) = "#{name}:#{args.inspect}"
end
class Tag
  def self.publish(name, level = 1) = "Tag.#{name}@#{level}"
end
class Fan
  def initialize = @subs = [Sub.new, Sub.new]
  def listeners_for(name) = @subs.select { |s| name != :none }
  def publish(name, ...) = listeners_for(name).map { |s| s.publish(name, ...) }
end
p Notes.publish(:a, 1, 2)
p Notes.publish(:b)
vals = [Sub.new, Tag]
args = [:x, 7]
p vals.map { |v| v.publish(*args) }
p vals.map { |v| v.publish(*[:y]) }
begin
  Tag.publish(*[:z, 1, 2])
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
