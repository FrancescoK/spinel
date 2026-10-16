# spinel: reject-subclass: unsupported defined?(super) where the method super reaches is not known
# Array has a singleton method [], which the table of builtin instance
# methods does not hold, so defined?(super) in a subclass's own self.[]
# (CRuby: "super") stays refused rather than answered nil.
class Seq < Array
  def self.[](*) = defined?(super)
end
p Seq[]
