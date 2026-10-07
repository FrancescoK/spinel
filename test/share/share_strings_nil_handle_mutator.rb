# A variable the rule makes the shared handle can still hold nil: here a
# method's value that is a String on one path and nil on the other. An
# in-place mutator on it raises NoMethodError for nil, as on a String
# variable that is not shared; the handle's mutators read and wrote
# through the NULL handle (a crash, or a change that went nowhere).
def id(x) = x

def run(k, name)
  r = id(k == 0 ? +"Hello" : nil)
  s = r
  begin
    case name
    when 0 then r.upcase!
    when 1 then r << "x"
    when 2 then r.concat("x")
    when 3 then r.sub!("H", "J")
    when 4 then r.replace("x")
    when 5 then r.clear
    when 6 then r[0] = "x"
    when 7 then r.insert(0, "x")
    when 8 then r.prepend("x")
    when 9 then r.strip!
    when 10 then r.slice!(0)
    when 11 then r.squeeze!
    when 12 then r.succ!
    end
  rescue NoMethodError => e
    puts e.message
  end
  p [r, s]
end

13.times { |i| run(0, i); run(1, i) }
