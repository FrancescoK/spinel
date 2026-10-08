# Two .rbs of one directory declare DupPaths.path with different signatures
# (a route helper each). The later would replace the earlier silently, and a
# call the earlier contradicts would build. It is an error, naming both.
#
# Not a snapshot test -- the Makefile runs it and asserts the diagnostic.
# spinel: rbs-seed-check
module DupPaths
  def self.path(show_read: nil, feed_id: nil)
    "/a" + (feed_id.nil? ? "" : "?f=#{feed_id.to_s}")
  end
end

puts DupPaths.path(feed_id: "all")
