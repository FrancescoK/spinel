# cause&.message where a class of the program overrides #message: nil when
# there is no cause, the override's answer when there is
class OwnMsg < StandardError
  def message = "own"
end
class WidgetError < StandardError
  def why = cause&.message
end
begin
  raise WidgetError, "one"
rescue StandardError => e
  p e.why
end
begin
  begin
    raise OwnMsg
  rescue
    raise WidgetError, "two"
  end
rescue WidgetError => e
  p e.why
end
