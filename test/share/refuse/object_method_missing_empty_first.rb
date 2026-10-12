# spinel: not-cruby
# Keep the refusal when a hook in a reopened Object can stand in: the
# receiver can be nil (`first` of an empty Array), whose class lacks the name and has Object's hook,
# which CRuby calls (here with no argument: it answers a global's String).
$object_hook = String.new("hook")
class Object
  def method_missing(name, *args) = $object_hook
end
class ObjectHookFirst
  def token = String.new("first")
end
class ObjectHookSecond
  def token = String.new("second")
end

receiver = (ARGV.empty? ? [] : [ObjectHookFirst.new, ObjectHookSecond.new]).first
token = receiver.token
saved = token
token << "-after"
puts saved
