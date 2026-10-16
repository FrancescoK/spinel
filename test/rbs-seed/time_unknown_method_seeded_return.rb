# Time has no to_date without `require "date"` (activesupport's
# TimeWithZone#to_date forwards to it). Spinel refuses the call, and with
# --defer-refusals raises at run time -- but it typed the call Integer, as it
# does Time's own accessors, so a `-> Date` seed on the method returning it
# was "contradicted" and the build stopped. A method Time does not have
# answers nothing the seed could disagree with.
#
# Not a snapshot test -- the Makefile builds it with --defer-refusals, so
# share-strings-test (which compiles without it) leaves it out.
# spinel: rbs-seed-check
# spinel: rbs-seed-no-share
class TUnkDate
  def initialize(y) = @y = y
end

class TUnkBox
  def initialize(t) = @t = t
  def to_date = @t.to_date
end

begin
  p TUnkBox.new(Time.at(0).utc).to_date
rescue NoMethodError, NotImplementedError
  puts "no to_date"
end
