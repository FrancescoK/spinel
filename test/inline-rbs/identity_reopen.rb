# A class opened in this file and reopened in a required one: each opening's
# annotations pin the one class, whichever file they are written in.
require_relative "identity_reopen_part"

class Shelf
  #: (untyped) -> untyped
  def put(x)
    x
  end
end

s = Shelf.new
p s.put(1)
p s.take(2)
p s.tag
