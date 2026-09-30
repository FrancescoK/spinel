# A braced Hash is a positional argument in Ruby 3, so a call into a method
# taking only a required keyword raises ArgumentError at the call site. The
# call's result still lands in a local typed from the method's Symbol
# literal while the method answers a boxed value: the assignment narrows it
# into the Symbol slot (#6009).
class Probe
  def show(widget)
    active = status_for({ widget: widget })
    puts active
  end

  def status_for(widget:)
    return :off if widget.nil?
    widget
  end
end

begin
  Probe.new.show("on")
rescue ArgumentError => e
  p e.message
end
