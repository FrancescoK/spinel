# A shared Struct member keeps its handle through a break value.
class StructBreakHandle
  St = Struct.new(:value)

  def run
    o = St.new(+"aabc")
    t = while true
      break o.value
    end
    puts o.value.frozen?.to_s + " " + t.frozen?.to_s
    begin
      o.value.upcase!
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts o.value.frozen?.to_s + " " + t.frozen?.to_s
    p([o.value, t])
  end
end

StructBreakHandle.new.run

# Mutating the break result reaches the member too.
o = StructBreakHandle::St.new(+"abc")
t = until false
  break o.value
end
t << "!"
p o.value, t
