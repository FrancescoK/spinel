# activesupport's Date#<=> over alias compare_without_coercion, with its
# own DateTime#<=> a super wrapper: CRuby's alias runs Date's <=> body on
# a DateTime too. It was refused by the alias settling (#9998).
require "date"
class Date
  alias_method :compare_without_coercion, :<=>
  def <=>(other)
    if other.respond_to?(:to_datetime) && !other.is_a?(Date)
      to_datetime <=> other.to_datetime
    else
      compare_without_coercion(other)
    end
  end
end
class DateTime
  def <=>(other)
    if other.respond_to?(:to_datetime)
      super other.to_datetime rescue nil
    else
      super
    end
  end
end
d = Date.new(2026, 1, 30)
dt = DateTime.new(2026, 1, 30, 12, 0, 0)
p d <=> Date.new(2026, 1, 31), d <=> dt, dt <=> d, dt.compare_without_coercion(d), d.compare_without_coercion(d)
