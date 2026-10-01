# An Exception held as the builtin type (`rescue => e`) is not answered 0 by
# identity when a class of the program defines `<=>`: it may be an instance of
# that class, whose method (nil here) answers.
class NilErr < StandardError
  def <=>(o) = nil
end

begin
  raise NilErr, "m"
rescue => e
  p e <=> e
end
