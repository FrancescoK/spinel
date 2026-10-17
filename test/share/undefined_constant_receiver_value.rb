# A call on a constant the program defines nowhere raises NameError before
# its value exists, so nothing is handed on: the writer that stores
# `Missing::Password.create(x).to_s` next to a String the program changes
# is not refused for the write it never makes (campfire's User#password=
# with bcrypt unavailable).
class U
  def initialize = (@pw = nil; @d = nil)
  def pw=(x)
    @pw = x
    if x.nil?
      nil
    else
      @d = Missing::Password.create(x).to_s
    end
  end
  def d = @d
  def pw = @pw
end
u = U.new
s = +"abc"
begin
  u.pw = s
rescue NameError => e
  puts e.class
end
s << "!"
p u.pw, u.d
