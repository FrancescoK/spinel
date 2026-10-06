# `raise C, s` makes s itself the exception's message. The message was a
# copy and s stayed "abc": refused, not compiled wrong.
s = +"abc"
begin
  raise ArgumentError, s
rescue => e
  e.message << "!"
end
p s
