# A call in String's reopening body, ahead of the def that replaces the
# method it calls, runs the builtin: the def has not run yet. The call
# after the body runs the program's method.
class String
  "ab".each_char { |c| print c }
  puts
  def each_char
    yield "X"
    self
  end
end
"ab".each_char { |c| print c }
puts
