# A shared Struct member keeps its handle through a throw value.
class StructThrowHandle
  St = Struct.new(:value)

  def run
    o = St.new(+"aabc")
    t = catch(:k) do
      throw :k, o.value
    end
    puts o.value.frozen?.to_s + " " + t.frozen?.to_s
    begin
      t.squeeze!
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts o.value.frozen?.to_s + " " + t.frozen?.to_s
    p([o.value, t])
  end
end

StructThrowHandle.new.run

# A boxed throw also keeps a frozen member's identity.
o = StructThrowHandle::St.new("frozen")
t = catch(:tag) { throw :tag, o.value }
p t.equal?(o.value), t.frozen?
