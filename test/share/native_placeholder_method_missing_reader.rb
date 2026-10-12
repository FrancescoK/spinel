# A native class's reader named method_missing is a hook only for an
# object of that class: the receiver here is never a StringIO, so CRuby
# never routes the call to it, and the fresh String the program's method
# answers keeps no other name.
require "stringio"
StringIO.new("loaded native class").read
class StringIO
  attr_reader :method_missing
end

class NativePlaceholderReaderFreshArm
  def freshness_probe_token = String.new("fresh")
end
receiver = [NativePlaceholderReaderFreshArm.new, Object.new][ARGV.length]
token = receiver.freshness_probe_token
saved = token
token << "-after"
puts saved
