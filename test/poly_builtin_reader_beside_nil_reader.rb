# A reader that can answer nil, named like a builtin's Integer or Float
# method: a call on a value that is either the object or the builtin
# answers the reader's nil, and the builtin's own answer.

class Rec
  attr_reader :pid, :utime, :stime, :to_i, :to_f, :ord, :length,
              :bytesize, :year, :hour, :arity

  def initialize(i, f)
    @pid = i; @to_i = i; @ord = i; @length = i; @bytesize = i
    @year = i; @hour = i; @arity = i
    @utime = f; @stime = f; @to_f = f
  end
end

def pid_of(m) = m.pid
def utime_of(m) = m.utime
def stime_of(m) = m.stime
def to_i_of(m) = m.to_i
def to_f_of(m) = m.to_f
def ord_of(m) = m.ord
def length_of(m) = m.length
def bytesize_of(m) = m.bytesize
def year_of(m) = m.year
def hour_of(m) = m.hour
def arity_of(m) = m.arity

full = Rec.new(3, 1.5)
empty = Rec.new(nil, nil)

[full, empty].each do |r|
  p [pid_of(r), to_i_of(r), ord_of(r), length_of(r), bytesize_of(r),
     year_of(r), hour_of(r), arity_of(r)]
  p [utime_of(r), stime_of(r), to_f_of(r)]
end

_, st = Process.wait2(Process.spawn("true"))
p pid_of(st) > 0
tms = Process.times
p utime_of(tms) >= 0.0, stime_of(tms) >= 0.0
p to_i_of("12"), to_f_of("2.5"), ord_of("a"), length_of("abc"), bytesize_of("abc")
t = Time.at(0).utc
p year_of(t), hour_of(t)
p arity_of(->(a, b) { a })
