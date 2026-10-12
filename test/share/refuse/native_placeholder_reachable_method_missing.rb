# spinel: not-cruby
# Keep the conservative refusal when a hook can stand in: the receiver can
# be of a class that has method_missing and not the name, which CRuby
# routes to the hook (here it does: the hook answers a global's String).
require "stringio"
StringIO.new("loaded native class").read

class NativePlaceholderHookOnly
  def method_missing(name, *args) = $native_placeholder_hook
end
class NativePlaceholderFreshArm
  def freshness_probe_token = String.new("fresh")
end
$native_placeholder_hook = String.new("hook")

receiver = [NativePlaceholderFreshArm.new, NativePlaceholderHookOnly.new][1 - ARGV.length]
token = receiver.freshness_probe_token
saved = token
token << "-after"
puts saved
