# The same contradiction one step earlier than seed_contradiction.rb: the
# argument, not an ivar. A Hash reaches a parameter the seed declares String.
# Both are heap pointers, but there is no conversion between the two layouts,
# so the emitted C would read the hash pointer as a C string.
#
# Not a snapshot test -- failing to compile is the passing outcome, so the
# Makefile runs it and asserts the diagnostic.
# spinel: rbs-seed-check
module ViewHelpers
  def self.html_escape(s)
    s
  end
end

p "<#{ViewHelpers.html_escape({ id: "edit_story" })}>"
