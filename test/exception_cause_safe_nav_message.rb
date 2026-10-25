# cause&.message in an exception's method: nil when there is no cause
class WidgetError < StandardError
  def why = self.cause&.message
  def why2 = (c = self.cause) ? c.message : nil
end
begin
  raise WidgetError, "one"
rescue StandardError => e
  p e.why, e.why2, e.cause&.message
end
