# The contradiction of seed_contradiction_arg.rb for a KEYWORD argument: true
# reaches a keyword the seed declares String?, and a String reaches one it
# declares Integer?. The call named the keyword, so the value is known, and a
# seed is trusted; a refusal at build time is the passing outcome, not a
# TypeError at run time.
#
# Not a snapshot test -- the Makefile runs it and asserts the diagnostic.
# spinel: rbs-seed-check
module KwPaths
  def self.show(show_read: nil)
    "/a" + (show_read.nil? ? "" : "?s=#{show_read.to_s}")
  end

  def self.feed(feed_id: nil)
    "/f" + (feed_id.nil? ? "" : "?f=#{feed_id.to_s}")
  end
end

puts KwPaths.show(show_read: true)
puts KwPaths.feed(feed_id: "all")
