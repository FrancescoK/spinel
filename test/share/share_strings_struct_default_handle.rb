# A shared Struct member keeps its handle through a default value.
class StructDefaultHandle
  St = Struct.new(:value)

  def run
    o = St.new("aab#{ARGV.size}")
    d = ->(v = o.value) { v }
    t = d.call
    puts (o.value.object_id == t.object_id).to_s
    begin
      t[0] = "Q"
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts (o.value.object_id == t.object_id).to_s
    p([o.value, t])
  end
end

StructDefaultHandle.new.run

# The supplied argument still replaces the default; a stored default
# and the Struct member observe changes in both directions.
o = StructDefaultHandle::St.new(+"abc")
f = ->(value = o.value) { value }
a = f.call
b = f.call(+"other")
o.value.upcase!
p a, b
