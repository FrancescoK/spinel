# A mixin into a builtin's singleton class through an explicit receiver is
# refused with a message rather than an internal "unsupported call".
module Shout
  def shout = "!"
end
String.singleton_class.include(Shout)
p String.shout
