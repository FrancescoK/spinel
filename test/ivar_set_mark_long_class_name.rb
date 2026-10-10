# An ivar store through a boxed receiver of a class with a long C name marks
# the ivar assigned whole: the mark's text outgrew a fixed buffer and the cut
# C did not compile (#8406).
class Widget
  attr_accessor :settings, :origin

  def origin? = instance_variable_defined?(:@origin)
end

class ExtraordinarilyLongNamedWidgetSubclassNumberOne < Widget
end

class ExtraordinarilyLongNamedWidgetSubclassNumberTwo < Widget
end

def pick(n)
  n.even? ? ExtraordinarilyLongNamedWidgetSubclassNumberOne.new : ExtraordinarilyLongNamedWidgetSubclassNumberTwo.new
end

[1, 2].each do |n|
  w = pick(n)
  w.origin = "o" if n > 1
  w.settings = n
  p [w.origin?, w.settings]
end
module AdministrationPanelControllers
  module ReportingAndAnalyticsSection
    class QuarterlyRevenueBreakdownController < Widget
    end
  end
end
[AdministrationPanelControllers::ReportingAndAnalyticsSection::QuarterlyRevenueBreakdownController.new, pick(1)].each do |w|
  w.origin = "x"
  w.settings = 3
  p [w.origin?, w.settings]
end
