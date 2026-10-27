# The program's last statement is a value nothing reads: a file's value goes
# nowhere. So a poly value there (`p` with two arguments answers an Array)
# does not make it a program with poly values, and an instance built there
# can still be a value type. (infer-test checks the define and the struct.)
class Box
  def initialize(v)
    @v = v
  end

  def v = @v
end
u = "éxéx"
p u.length, Box.new(u.bytesize).v
