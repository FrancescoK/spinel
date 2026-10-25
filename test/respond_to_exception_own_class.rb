# respond_to? on a rescued exception answers by the class it holds: a name
# only one of the program's exception classes defines is not every
# exception's
class WidgetError < StandardError
  def label; "w"; end
end
class SubWidgetError < WidgetError
end
class GadgetError < StandardError
  private

  def hidden; "h"; end
end

def check(e)
  [e.respond_to?(:label), e.respond_to?(:hidden), e.respond_to?(:hidden, true), e.respond_to?(:message)]
end

[GadgetError, WidgetError, SubWidgetError, RuntimeError].each do |k|
  begin
    raise k, "x"
  rescue StandardError => e
    p [k, e.respond_to?(:label)]
    p(e.respond_to?(:label) ? e.label : nil)
    p check(e)
  end
end

begin
  1 / 0
rescue => e
  p [e.class, e.respond_to?(:label), e.respond_to?(:message)]
end
