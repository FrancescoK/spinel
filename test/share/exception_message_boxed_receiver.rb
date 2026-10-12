# An exception's message read off a receiver whose class is known only at run
# time, where every class it can hold is an exception class, is the String the
# exception keeps, as off a receiver typed as the exception: changed through
# the variable it was read into, it is changed in the exception too, and a
# message given as a shared String is that String.
class B < StandardError; end
class C < StandardError; end
class D < StandardError
  def message = "own"
end

arr = [B.new("a#{ARGV.size}"), C.new(+"c")]
arr.each_with_index { |x, i| p [i, x.message.equal?(x.message)] }
v = arr[0].message
v << "!"
p arr[0].message, v
w = arr[1].message
w << "#"
p arr[1].message, w

# a message given as a String the program keeps
m = +"shared"
arr2 = [B.new(m), StandardError.new(m)]
arr2.each { |e| x = e.message; x << "." }
p m, arr2.map(&:message)

# no message given: the class name, a new String each time
[C.new, B.new(nil)].each { |e| y = e.message; y << "+"; p y, e.message }

# a class that overrides message answers its own String
[B.new(+"b"), D.new(+"d")].each do |e|
  z = e.message
  z << "!" unless z.frozen?
  p z, e.message
end

# an override that answers a new String from super's beside an exception
# that keeps the shared String itself
class F < StandardError; def message = "F:" + super; end
mf = +"mf"
[F.new(mf), StandardError.new(mf)].each { |e| e.message << "." }
p mf

# a Struct whose member is named message, in the same box
SM = Struct.new(:message)
[B.new(+"a"), C.new(+"c"), SM.new(+"sm")].each { |e| v = e.message; v << "!"; p [v, e.message] }

# an override that answers super alone hands on the String the exception
# keeps, off a boxed receiver and off a typed one
class G < StandardError; def message = super; end
class H < G; end
class J < StandardError; def to_s = super; end
mg = +"mg"
[G.new(mg), StandardError.new(mg)].each { |e| e.message << "." }
p mg
G.new(mg).message << "1"
H.new(mg).message << "2"
J.new(mg).to_s << "3"
p mg, G.new(mg).message.equal?(mg)
begin
  raise H, mg
rescue G => e
  e.message << "4"
end
p mg, [G.new, H.new(nil)].map(&:message)

# a Struct member named message beside exceptions, with and without an
# override answering super: each hands on the String it keeps
SM2 = Struct.new(:message)
class G2 < StandardError; def message = super; end
m2 = +"m"
pa = [StandardError.new(m2), SM2.new(m2)]
pa.each { |q| s2 = q.message; s2 << "." }
p m2, pa.map { |q| q.message.equal?(m2) }
pb = [G2.new(m2), SM2.new(m2)]
pb.each { |q| s3 = q.message; s3 << "+" }
p m2, pb.map { |q| q.message.equal?(m2) }

# an override answering super where the class or one below it defines
# #to_s: the #to_s's String
class G3 < StandardError
  def initialize(t) = (@t = t; super("g"))
  def message = super
  def to_s = @t
end
class H3 < StandardError; def message = super; end
class H4 < H3; def to_s = "H4:" + super; end
t3 = +"t"
g3 = G3.new(t3)
g3.message << "1"
p t3, g3.message.equal?(t3)
m3 = +"m"
[H3.new(m3), H4.new(m3), StandardError.new(m3)].each { |e| e.message << "." }
p m3, H4.new(m3).message

# exceptions raised from a class held in a variable, rescued into an Array:
# each keeps the String it was given, through an override answering super
class B5 < StandardError; def message = super; end
class D5 < StandardError; end
m5 = +"msg"
errs5 = []
[B5, D5].each do |k|
  begin
    raise k, m5
  rescue => e
    errs5 << e
  end
end
errs5.each { |e| e.message << "!" }
p m5, errs5.map(&:message), errs5.map { |e| e.message.equal?(m5) }
p errs5.map(&:inspect)

# the same pairs held in an Array of Arrays, which the walk cannot follow
m6 = +"n"
[[StandardError.new(m6), SM2.new(m6)], [G2.new(m6), SM2.new(m6)]].each do |pr|
  pr.each { |q| s6 = q.message; s6 << "." }
  p m6, pr.map { |q| q.message.equal?(m6) }
end

# a class that overrides only #to_s, answering a String a global or a field
# keeps: #message answers that String, off a box beside other exceptions
class H7 < StandardError; def to_s = $g7; end
$g7 = +"g"
es7 = [H7.new(+"m"), RuntimeError.new(+"r")]
es7.each { |e| v = e.message; v << "!" }
p $g7, es7.map(&:message)
class G8 < StandardError; end
class H8 < G8; def to_s = @k ||= +"hk"; end
es8 = [G8.new(+"m"), H8.new(+"m")]
es8.each { |e| e.message << "!" }
p es8.map(&:message), es8.map(&:to_s)

# raise with an exception object and a shared message: the copy keeps it
class B14 < StandardError; end
m14 = +"o"
[B14, B14.new(+"pre")].each do |k|
  begin
    raise k, m14
  rescue => e
    e.message << "!"
    p e.message
  end
end
e14 = B14.new(+"pre")
begin
  raise e14, m14
rescue => e
  e.message << "?"
end
p m14
