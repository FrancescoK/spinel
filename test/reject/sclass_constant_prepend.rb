# A prepend inside `class << Const` (not `class << self` in the class body)
# is refused: left alone it was dropped, and the class's own method answered
# where CRuby answers the prepended module's.
module Logged
  def call(x) = super(x) + 1
end
class Svc
  def self.call(x) = x * 10
end
class << Svc
  prepend Logged
end
p Svc.call(5)
