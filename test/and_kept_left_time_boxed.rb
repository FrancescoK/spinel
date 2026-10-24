# `t && t.year` where t is a Time local and the chain's value is boxed: the
# kept-left arm was the raw sp_Time * beside the boxed right arm, and the
# C conditional did not compile (#10078). It is boxed as a Time.
class Widget
  def stamp
    t = clock && Time.at(0)
    t && t.year
  end
end

begin
  p Widget.new.stamp
rescue NameError => e
  puts "#{e.class}: #{e.name}"
end
class Gadget; end
class Widget2
  def seen_t(w)
    t = w.seen && Time.at(0)
    t && t.year
  end
  def ok
    t = Time.at(0).utc
    t && t.year
  end
  def rng
    r = (1..3)
    (r && r.size) || r
  end
end
begin
  p Widget2.new.seen_t(Gadget.new)
rescue NoMethodError => e
  puts "#{e.class}: #{e.name}"
end
p Widget2.new.ok
p Widget2.new.rng
