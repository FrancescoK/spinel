module Quiet
  def say = "quiet"
end
class Speaker
  include Quiet
end
