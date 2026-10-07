# Flag-only: Kernel#String keeps a boxed String's handle and frozen mark.
# Non-String boxes still use the ordinary conversion, evaluated once.
class BoxedStringConversion
  def run
    h = { k: "a\0bc" }
    t = String(h[:k])
    p h[:k].frozen?, t.frozen?, h[:k].equal?(t)
    begin
      t.prepend("p")
    rescue => e
      p e.class
    end
    p [h[:k], t]

    a = [+"abc"]
    u = String(a[0])
    u << "!"
    p a[0].equal?(u), [a[0], u]
    String(a[0]).prepend("p")
    p [a[0], u]
  end
end

class StringConversionSource
  def to_str
    puts "to_str"
    "converted"
  end
end

def convert_box(v)
  t = String(v)
  t << "!" unless t.frozen?
  p t
end

BoxedStringConversion.new.run
[nil, 12, true, "frozen", StringConversionSource.new].each do |v|
  convert_box(v)
end
