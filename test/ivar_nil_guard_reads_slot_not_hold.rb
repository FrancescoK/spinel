# The nil test of << on an ivar that can be nil reads the ivar in its slot:
# the receiver's hold (the bang's handle temp) is declared inside the
# expression the test goes ahead of, and the test read that temp before
# its declaration (#10017).
Info = Struct.new(:kind, :elem)

class Gen
  def initialize
    @out = +""
  end

  def c_type(t)
    "T_#{t}"
  end

  def emit(info)
    case info.kind
    when :array
      @out << "typedef #{c_type(info.elem)};\n"
    end
  end

  def capture
    saved = @out
    yield
  ensure
    @out = saved
  end
end

g = Gen.new
g.capture { 1 }
p g.emit(Info.new(:array, "i64"))
