p :before
class CalendarBase
  include Comparable
  START = 2299161
end
class CalendarChild < CalendarBase
  def start(value = CalendarBase::START)
    value
  end
end
p CalendarChild.new.start
module Comparable
  TOKEN = 17
end
class ReopenedMixin
  include Comparable
  def token(value = TOKEN)
    value
  end
end
p ReopenedMixin.new.token
class MathMixin
  include Math
  def pi
    PI
  end
end
p MathMixin.new.pi
