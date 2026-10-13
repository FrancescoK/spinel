# A call with no arguments on a boxed receiver (one of several classes) to a
# method whose default reads an earlier parameter, as Thor's Shell#say is.
class Basic
  def say(message = "", color = nil, force_new_line = (message.to_s !~ /( |\t)\z/))
    print message.to_s
    print "\n" if force_new_line
    nil
  end
end
class Color < Basic
end
def shell(n) = n.zero? ? Basic.new : Color.new
[0, 1].each do |n|
  s = shell(n)
  s.say "hi"
  s.say
  s.say "tab\t"
  puts "|"
end
Basic.new.say
puts "direct"
