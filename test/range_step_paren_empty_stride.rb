# An empty container stride in parentheses, or built by Array.new / Hash.new,
# raises the same TypeError as a bare `[]` / `{}`.
[-> { (1..3).step(([])) { } }, -> { ("a".."c").step(({})) { } },
 -> { (1.0..2.0).step(([])) { } }, -> { (1..3).step(Array.new) { } },
 -> { ("a".."c").step(Array.new) { } }, -> { (1.0..2.0).step(Hash.new) { } }].each do |f|
  begin
    f.call
  rescue TypeError => e
    p e.message
  end
end
