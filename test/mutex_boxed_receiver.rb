# A Mutex read back out of a Hash or an Array is boxed, and still answers
# lock, unlock, try_lock, locked? and owned? as a Mutex, in a condition too.
# A per-key lock table is the usual shape.
locks = Hash.new { |hash, key| hash[key] = Mutex.new }
m = locks["a"]

p [m.locked?, m.owned?]
p m.try_lock ? :acquired : :busy
p [m.locked?, m.owned?, m.try_lock]
p m.unlock.equal?(m)
p m.lock.equal?(m)
p Thread.new { [m.try_lock, m.locked?, m.owned?] }.value
m.unlock

begin
  m.unlock
rescue ThreadError
  p :not_locked
end

other = [locks["b"], 1, "x"]
p other[0].try_lock
p other[0].owned?
begin
  other[1].try_lock
rescue NoMethodError
  p :no_method
end

# a user class that owns the same names does not take them from the mutex
class Gate
  def lock = :gate
  def locked? = :gate
end
items = [Mutex.new, Gate.new]
p items.map { |x| x.lock.class }
p items.map(&:locked?)
