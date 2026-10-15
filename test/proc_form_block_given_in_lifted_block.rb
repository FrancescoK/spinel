class Locker
  def self.with_lock(lock)
    lock.synchronize { yield }
  end

  def self.open(lock, name)
    file = with_lock(lock) do
      raise ArgumentError, "open requires a block" unless block_given?
      name + 1
    end
    yield file
  end
end

class Pointer
  def self.synchronize(&block) = block.call
end

class Box
  def open(lock, name) = yield(name + 1)
end

out = []
[Box.new, Locker].each { |b| b.open(Mutex.new, 7) { |f| out << f } }
puts out.join(",")

[Box.new, Locker].each do |b|
  begin
    b.open(Mutex.new, 8)
  rescue ArgumentError, LocalJumpError => e
    puts e.class
  end
end
