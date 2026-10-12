# A method_missing hook in a class that answers the name itself stands in
# for no call of that name: the receiver's classes all define
# freshness_probe_token, the inheriting one too, so CRuby never routes the
# call to the hook, and the fresh String each answers keeps no other name.
require "stringio"
StringIO.new("loaded native class").read

class NativePlaceholderHookBase
  def method_missing(name, *args) = +"hook"
  def freshness_probe_token = String.new("fresh")
end
class NativePlaceholderHookChild < NativePlaceholderHookBase; end
class NativePlaceholderFreshArm
  def freshness_probe_token = String.new("fresh")
end

receiver = [NativePlaceholderFreshArm.new, NativePlaceholderHookChild.new][ARGV.length]
token = receiver.freshness_probe_token
saved = token
token << "-after"
puts saved
