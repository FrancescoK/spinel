class MyErr < StandardError
  def initialize(m = "dflt")
    super
    @k = 1
  end
end
class Plain < RuntimeError; end
p Marshal.dump(ArgumentError.new("boom"))
e = RuntimeError.new("x"); e.set_backtrace(["a:1", "b:2"])
p Marshal.dump(e)
p Marshal.dump(Plain.new("p"))
p Marshal.dump(MyErr.new)
p Marshal.dump(RuntimeError.new)
p Marshal.dump([e, e])
begin
  raise ArgumentError, "raised"
rescue => r
  p Marshal.dump(r).bytesize > 0
end
v = [1, ArgumentError.new("in")][1]
p Marshal.dump(v)
