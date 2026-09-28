# raise with a user exception class held in a variable runs that class's own
# initialize, as the constant form does; a boxed exception answers the
# accessors a typed one does
class WrapErr < StandardError
  def initialize(m = "dflt") = super("wrapped #{m}")
end
class NoDflt < StandardError
  def initialize(m)
    super("nd:#{m}")
  end
end
class CodeErr < StandardError
  def initialize(msg = "code err", code = 7)
    @code = code
    super("#{msg} [#{code}]")
  end
end
class SubWrap < WrapErr; end
class Plain < StandardError; end
class ZeroArg < StandardError
  def initialize = super("zero")
end
class Rest < StandardError
  def initialize(m = "r", *extra) = super("rest #{m} #{extra.size}")
end
module App
  class Failed < StandardError
    def initialize(m = "failed") = super("app: #{m}")
  end
end
class Over < StandardError
  def message = "over!"
end

def r1(k) = raise(k, "boom")
def r2(k) = raise(k)
def t
  yield
rescue => e
  p [e.class, e.message]
end

[WrapErr, NoDflt, CodeErr, SubWrap, Plain, ZeroArg, Rest, App::Failed].each do |k|
  t { r1(k) }
  t { r2(k) }
end
t { r1(RuntimeError) }
t { r2(String) }
t { raise WrapErr, "literal" }
t { raise WrapErr, nil }
t { raise WrapErr }
@k = WrapErr
t { raise @k, "ivar" }
$k = SubWrap
t { raise $k }
k2 = [WrapErr, 1][0]
t { raise k2, nil }
t { raise k2, 42 }
t { raise [WrapErr.new("obj"), 1][0], "object" }
t do
  begin
    raise "inner"
  rescue => ie
    raise [App::Failed][0], "outer", cause: ie
  end
rescue => e
  p [e.message, e.cause.message]
end

a = [StandardError.new("x"), 1]
p a[0].backtrace
p a[0].cause
b = [Plain.new("y"), 2]
p b[0].backtrace
o = [Over.new("z"), 3][0]
p o.detailed_message
begin
  raise "q"
rescue => r
  arr = [r, 1]
  p arr[0].backtrace.class
  p arr[0].cause
end
