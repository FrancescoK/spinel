# merge!/update/merge with a splatted list of Hashes: a String value read
# from a String-valued member is stored as a String (it was refused as "no
# String" once the list held two or more Hashes), a member keeps sharing its
# String with the program, and a member that is no Hash raises CRuby's
# TypeError instead of being skipped
h = {"a" => "b"}
arr = [{"c" => "d"}, {"e" => "f"}]
p h.merge!(*arr).equal?(h)
p h
p h.merge(*arr, *[{"g" => "h"}])
n = {1 => "b"}
n.update(*[{2 => "d"}, {3 => "f"}])
p n
s = +"q"
t = {"a" => "b"}
t.merge!(*[{"c" => s}, {"a" => "z"}])
s << "!"
p t
def m(h, list) = h.merge!(*list)
p m({"x" => "y"}, [{"c" => "d"}, {"x" => "w"}])
class W
  def to_hash = {"w" => "x"}
end
w = {"a" => "b"}
ws = [{"c" => "d"}, W.new]
w.merge!(*ws)
p w
w.merge!({"y" => "z"}, W.new)
p w
[[{"c" => "d"}, nil], [{"c" => "d"}, 5]].each do |list|
  u = {"a" => "b"}
  begin
    u.merge!(*list)
  rescue TypeError => e
    puts "TypeError: #{e.message}"
  end
  p u
  begin
    p u.merge(*list)
  rescue TypeError => e
    puts "TypeError: #{e.message}"
  end
end
# a member's #to_hash that changes the list does not change which members
# merge in, and a receiver that only the call holds stays alive across it
$list = nil
class V
  def to_hash
    $list[2] = {"z" => "late"} if $list
    GC.start
    {"v" => "x"}
  end
end
def fresh = {"a" => "b"}
$list = [{"c" => "d"}, V.new, {"e" => "f"}]
p fresh.merge!(*$list)
$list = [{"c" => "d"}, V.new, {"e" => "f"}]
p fresh.merge(*$list)
