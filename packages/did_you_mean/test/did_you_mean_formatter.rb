# DidYouMean::Formatter writes suggestions as "Did you mean?" lines, each
# one under the first; DidYouMean.formatter is the one in use, and a
# program can set its own.
require "did_you_mean"

p DidYouMean::Formatter.message_for([])
puts DidYouMean::Formatter.message_for(%w[bar])
puts DidYouMean::Formatter.message_for(%w[bar baz qux])
p DidYouMean.formatter == DidYouMean::Formatter
p DidYouMean::PlainFormatter == DidYouMean::Formatter
p DidYouMean::VERSION

class Shouting
  def self.message_for(corrections) = " MAYBE #{corrections.join(" OR ").upcase}?"
end

DidYouMean.formatter = Shouting
puts DidYouMean.formatter.message_for(%w[bar baz])
DidYouMean.formatter = DidYouMean::Formatter
puts DidYouMean.formatter.message_for(%w[bar])

# the deprecated instance method answers through the receiver's class, so a
# subclass's own message_for is the one used (its warning goes to $stderr)
class Loud < DidYouMean::Formatter
  def self.message_for(corrections) = "LOUD: #{corrections.join(",")}"
end
$stderr = File.open(File::NULL, "w")
p Loud.new.message_for(%w[a b])
p DidYouMean::Formatter.new.message_for(%w[x])
