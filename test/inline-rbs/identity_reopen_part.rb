# The second opening of Shelf, pulled in by identity_reopen.rb.
class Shelf
  #: (untyped) -> untyped
  def take(x)
    x
  end

  attr_reader :tag #: String?

  def initialize
    @tag = nil
  end
end
