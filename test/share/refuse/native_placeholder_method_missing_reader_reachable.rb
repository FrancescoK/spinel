# spinel: not-cruby
# Keep a native class's reader named method_missing among the hooks when
# the receiver can be an object of that class (here it is).
require "stringio"
class StringIO
  attr_reader :method_missing
end

class NativePlaceholderReaderFreshArm
  def freshness_probe_token = String.new("fresh")
end
receiver = [NativePlaceholderReaderFreshArm.new, StringIO.new("io")][1 - ARGV.length]
token = receiver.freshness_probe_token
saved = token
token << "-after"
puts saved
