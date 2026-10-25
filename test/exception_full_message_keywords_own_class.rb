# full_message and detailed_message with their keywords on the program's
# exception class, with self or an implicit self: the rendering the
# keywordless call gives
class WidgetError < StandardError
  def fm = self.full_message(highlight: false) == self.full_message
  def fm_bare = full_message(highlight: false, order: :top) == full_message
  def dm = detailed_message(highlight: false)
end
begin
  raise WidgetError, "one"
rescue WidgetError => e
  p e.fm, e.fm_bare, e.dm
  p e.detailed_message(highlight: false)
end
