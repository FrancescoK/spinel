class Box
  def initialize(k)
    @v = k == 0 ? +"hello" : [3, 1, 2, 2]
  end
  def v = @v
  def cat = @v.concat([4])
  def pre = @v.prepend(0)
  def srt = @v.sort!
  def rot = @v.rotate!
  def rev = @v.reverse!
  def uq = @v.uniq!
  def cmp = @v.compact!
  def sel = @v.select! { |x| x < 4 }
  def kif = @v.keep_if { |x| x < 4 }
  def fl = @v.fill(7)
  def scat = @v.concat("!")
end

a = Box.new(1)
%i[cat pre srt rot rev uq cmp sel kif fl].each do |m|
  r = a.send(m)
  p [m, r, r.equal?(a.v)]
end
a.cat << 9
p a.v

s = Box.new(0)
r = s.scat
p r.equal?(s.v)
r.sub!("l", "L")
p s.v
p s.rev.equal?(s.v), s.v
