# spinel: share
Entry = Struct.new(:lock)

class Box
  def initialize(target)
    @target = target
  end

  def store(value)
    @target[0] = value
  end
end

entry = Entry.new(Mutex.new)
hash = {}
array = [+"initial"]
first = +"hash"
second = +"array"
Box.new(hash).store(first)
Box.new(array).store(second)
first << "!"
second << "!"
p hash[0], array[0]
p entry.lock.locked?
