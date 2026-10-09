# Class.new classes (one only displayed) in NoMethodError texts and class
# names from several Thread workers at once. The unnamed form of a class is
# built once and published for every worker (sp_class_display), and a raise
# site keeps the text it built for the display it saw (per worker): neither
# may be torn or shared while two workers run the same site.
k = Class.new
j = Class.new
def boom(o)
  o.nope
rescue NoMethodError => e
  e.message.sub(/0x\h+/, "0xX")
end

def shown(c)
  c.to_s.sub(/0x\h+/, "0xX")
end

ts = 8.times.map do
  Thread.new do
    a = []
    200.times { a << boom(k.new) << shown(k) << shown(j) }
    a.uniq
  end
end
p ts.flat_map(&:value).uniq

# the first display of each class is made by the workers themselves
k2 = Class.new
ts = 8.times.map { Thread.new { shown(k2) } }
p ts.map(&:value).uniq

# a name assigned while no worker runs shows from the next raise on
Named = k
ts = 8.times.map { Thread.new { [boom(k.new), shown(k), shown(j)] } }
p ts.map(&:value).uniq

# the main thread reads the same texts after the workers are done
p boom(k.new), shown(k), shown(j)

# the name is assigned while the workers run: each sees the unnamed form first
# and the constant's name once it is assigned
k3 = Class.new
ready = Queue.new
ts = 4.times.map do
  Thread.new do
    first = shown(k3)
    ready << 1
    Thread.pass until shown(k3) == "Named3"
    msg = begin
      k3.new.nope
    rescue NoMethodError => e
      e.message
    end
    [first, shown(k3), msg]
  end
end
4.times { ready.pop }
Named3 = k3
p ts.map(&:value).uniq
