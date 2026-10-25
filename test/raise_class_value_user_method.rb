# raise on a Class value builds whichever exception class the value holds:
# a method only that class defines answers on the rescued exception
class WidgetError < StandardError
  def label; "w:#{message}"; end
end
class GadgetError < StandardError
  def label; "g:#{message}"; end
end

k = WidgetError
begin
  raise k, "one"
rescue StandardError => e
  p e.label
end

[GadgetError, WidgetError].each do |kl|
  begin
    raise kl, "two"
  rescue StandardError => e
    p [e.class, e.label]
  end
end

def fail_with(kl) = raise(kl)
begin
  fail_with(GadgetError)
rescue => e
  p e.label
end
