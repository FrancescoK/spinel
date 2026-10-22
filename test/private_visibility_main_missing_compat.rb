# spinel: not-cruby
# Main retains master's private-call answer when Object defines a missing hook.
class Object
  def method_missing(name, *args) = "mm:#{name}"
end
class MissingViaObjectAncestor
  private def x = 6
  def run = (self).x
end
p MissingViaObjectAncestor.new.run
def missing_main_helper = 5
begin
  p((self).missing_main_helper)
rescue NoMethodError => e
  puts e.message
end
puts "done"

# An inherited private Object method also keeps master's hook behavior.
class Object
  private def visibility_object_private = 9
end
class VisibilityObjectMissingChild
  def run = (self).visibility_object_private
end
p VisibilityObjectMissingChild.new.run
