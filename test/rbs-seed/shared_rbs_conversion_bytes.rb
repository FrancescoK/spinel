# Under --share-strings (#6765), a String conversion (`to_s`, `to_str`,
# `itself`) over a value that holds no shared handle (an element of a new
# Array, a call's new String) is a String value like the operand alone: a
# container that keeps it wraps the bytes in a new handle, and a change
# through the container's other name reaches the element. The conversion
# was typed as the handle its operand hands on, but the operand had none to
# hand on, so the value was formed as bytes and held as an `sp_String *`:
# the C did not build (the `where` of a Hash walk pushing
# `"#{key}.#{col}".split(".").last.to_s` into an ivar Array that two writes
# make boxed). A conversion over a handle (a String parameter the method
# keeps) still hands that handle on: the element is the caller's String.
class CvCols
  def initialize
    @cols = []
  end
  attr_reader :cols

  def add(h)
    @cols = []
    h.each do |key, val|
      if val.is_a?(Hash)
        val.each { |col, v| @cols << "#{key}.#{col}".split(".").last.to_s }
      else
        @cols << +key.to_s   # (+: a Symbol's to_s is frozen in Spinel)
      end
    end
    self
  end

  def conv(s)
    @cols = []
    @cols << s.split(".").last.to_str
    @cols << s.split(".").first.itself
    @cols << s.split(".").last.to_s.to_s
    @cols << File.basename(s).to_s
    @cols << s[0, 3].to_s
    @cols << s.chars.first.to_s
    self
  end

  def keep(s)
    @cols = []
    @cols << s.to_s
    @cols << s.to_s.to_s
    self
  end
end

r = CvCols.new.add({ a: 1, "z" => 2, b: { c: 3 } })
w = r.cols.map { |c| c }
w[0] << "!"
w[2] << "?"
p r.cols
p w[0].equal?(r.cols[0])

r = CvCols.new.conv(+"x.y")
w = r.cols
w.each { |c| c << "!" }
p r.cols
p w[0].equal?(r.cols[0])

buf = +"ab"
r = CvCols.new.keep(buf)
buf << "!"
p r.cols
p r.cols[0].equal?(buf), r.cols[1].equal?(buf)
