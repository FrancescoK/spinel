# A user detailed_message receives the keywords itself.
class OverError < RuntimeError
  def detailed_message(highlight: false, **extra)
    "override: #{highlight.inspect} #{extra.inspect}"
  end
end
p OverError.new("over").detailed_message(highlight: true, extra: 7)
