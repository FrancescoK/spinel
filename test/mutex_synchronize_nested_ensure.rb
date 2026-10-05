# A begin..ensure nested in a Mutex#synchronize block hands its deferred
# `next`, `break` and exception object to the synchronize's unlock frame,
# which declared none of those fields: the C did not build (#7342). The
# exception object also has to survive the unlock and the re-raise.
class Tagged < StandardError
  attr_reader :tag
  def initialize(msg, tag)
    super(msg)
    @tag = tag
  end
end

mutex = Mutex.new
mutex.synchronize do
  begin
    puts "body"
  ensure
    puts "inner ensure"
  end
end
puts mutex.locked?

# the exception object, not only its class and message, comes out
begin
  mutex.synchronize do
    begin
      raise Tagged.new("boom", 42)
    ensure
      puts "cleanup"
    end
  end
rescue Tagged => e
  puts "#{e.class}: #{e.message} tag=#{e.tag}"
end
puts mutex.locked?

begin
  mutex.synchronize { raise Tagged.new("plain", 7) }
rescue Tagged => e
  puts "#{e.message} tag=#{e.tag}"
end
puts mutex.locked?

# inside an iterator: next and break leave through both ensures
out = []
[1, 2, 3, 4].each do |i|
  mutex.synchronize do
    begin
      next if i == 2
      break if i == 4
      out << i
    ensure
      out << -i
    end
  end
end
p out
puts mutex.locked?

def with_cleanup
  yield
ensure
  puts "helper ensure"
end

def guarded(m)
  m.synchronize do
    with_cleanup do
      begin
        return :early
      ensure
        puts "deep ensure"
      end
    end
  end
end
p guarded(mutex)
puts mutex.locked?

# two synchronizes nested, with an ensure in between
m2 = Mutex.new
begin
  mutex.synchronize do
    begin
      m2.synchronize do
        begin
          raise Tagged.new("nested", 3)
        ensure
          puts "innermost"
        end
      end
    ensure
      puts "between #{m2.locked?}"
    end
  end
rescue Tagged => e
  puts "#{e.message} tag=#{e.tag} #{mutex.locked?} #{m2.locked?}"
end
