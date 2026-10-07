# A poly attribute write on a freeze-observed class whose C name is long: the
# frozen guard's receiver cast is as long as the name, not cut at a buffer.
class RepresentationsRedirectControllerWithAQuiteLongDescriptiveName
  attr_accessor :params
end

class Short
  attr_accessor :params
end

def make(flag)
  flag ? Short.new : RepresentationsRedirectControllerWithAQuiteLongDescriptiveName.new
end

ctl = make(ARGV.empty?)
ctl.freeze if ARGV.size > 3
ctl.params = { "k" => "v" }
puts ctl.params["k"]
ctl = make(false)
ctl.params = { "k" => "w" }
puts ctl.params["k"]
ctl.freeze
begin
  ctl.params = { "k" => "x" }
rescue FrozenError
  puts "frozen"
end
