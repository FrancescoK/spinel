# detailed_message(highlight:) on a boxed receiver checks the receiver at
# run time; a user subclass renders its own class name.
e = RuntimeError.new("boom")
kw = {highlight: true}
def first(a); a[0]; end
p first([e, 1]).detailed_message(**kw)
[RuntimeError.new("boxed"), 1, nil].each do |x|
  begin
    p first([x, :other]).detailed_message(highlight: true)
  rescue NoMethodError => error
    p [error.class, error.name]
  end
end

class SubError < RuntimeError; end
s = SubError.new("sub")
p s.detailed_message(highlight: true)
begin
  raise s
rescue SubError => rescued
  p rescued.detailed_message(highlight: true)
end

$events = []
class OrderError < RuntimeError
  def to_s
    $events << :message
    "order"
  end
end
def receiver
  $events << :receiver
  OrderError.new("ignored")
end
def option
  $events << :option
  true
end
p receiver.detailed_message(extra: ($events << :extra), highlight: option)
begin
  p OrderError.new("ignored").detailed_message(highlight: 1, extra: ($events << :extra))
rescue => error
  p [error.class, error.message]
end
p $events
