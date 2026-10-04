# instance_variable_set on a boxed receiver that may be any object (a
# rescued exception, among others) lays the ivar out on every program
# class. A reopened builtin (Hash here) is no such class: its instances are
# the runtime's own structs, with no room for the program's ivars. The
# dispatch wrote one through a type that does not exist, and the C did not
# compile. activesupport's ErrorReporter marks a reported error this way.
class Hash
  def size2 = size * 2
end
class Rep
end
class ReportedError < StandardError
end
def report(error)
  error.instance_variable_set(:@reported, true)
  error.instance_variable_get(:@reported)
end
begin
  raise ReportedError, "bad"
rescue => e
  report(e)
  p e.message
end
p report(Rep.new)
p Marshal.load(Marshal.dump({ a: 1 })).size2
