# Exception's own methods called on an implicit self from a method of the
# program's exception class answer as `self.message` does
class WidgetError < StandardError
  def label = "w:#{message}"
  def bt = backtrace.nil?
  def why = cause && cause.message
  def fm = full_message.include?("WidgetError")
  def dm = detailed_message
  def setbt = set_backtrace(["here:1"])
end
class OwnMsg < StandardError
  def message = "own"
  def label = "o:#{message}"
end
begin
  raise WidgetError, "one"
rescue StandardError => e
  p e.label, e.bt, e.why, e.fm, e.dm
  e.setbt
  p e.backtrace
end
begin
  begin
    raise "inner"
  rescue => x
    raise WidgetError, "outer"
  end
rescue WidgetError => e
  p e.why
end
begin
  raise OwnMsg, "x"
rescue => e
  p e.label
end
