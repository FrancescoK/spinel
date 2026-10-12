# spinel: not-cruby
# Keep the refusal when a module's hook can stand in: the receiver can be
# of a class that includes the module and lacks the name, which CRuby
# routes to the hook (here it does: the hook answers a global's String).
$module_hook = String.new("hook")
module ReachableHook
  def method_missing(name, *args) = $module_hook
end
class ReachableHookLacker
  include ReachableHook
end
class ReachableHookAnswerer
  include ReachableHook
  def token = String.new("fresh")
end

receiver = [ReachableHookAnswerer.new, ReachableHookLacker.new][1 - ARGV.length]
token = receiver.token
saved = token
token << "-after"
puts saved
