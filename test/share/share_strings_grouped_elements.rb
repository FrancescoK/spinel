# Flag-only: grouping iterators hand on the receiver's String objects.
# A chained materializer may leave its receiver's type unresolved; its
# element share relation must still reach the consuming block.
split = [+"x", +"y", +"z"]
split.slice_when { |left, right| left == "y" }.each { |run| run[0] << "!" }
p split

joined = [+"x", +"y", +"z"]
joined.chunk_while { |before, after| before == "x" }.each { |chunk| chunk[0] << "!" }
p joined

named = [+"x", +"y", +"z"]
named.slice_when { |first, second| first == "y" }.to_a.each do |piece|
  s = piece[0]
  s << "?"
end
p named

deferred = [+"x", +"y", +"z"]
chunks = deferred.chunk_while { |a, b| a == "x" }
chunks.each { |part| part[0] << "+" }
p deferred

replaced = [+"x", +"y", +"z"]
replaced.slice_when { |prev, next_value| prev == "y" }.each { |copy| copy[0] = +"z" }
p replaced

before = [+"x", +"y", +"z"]
before.slice_before { |s| s == "y" }.each { |run| run[0] << "!" }
p before

after = [+"x", +"y", +"z"]
after.slice_after { |s| s == "y" }.each { |run| run[0] << "!" }
p after

last = [+"x", +"y", +"z"]
last.slice_before { |s| s == "z" }.to_a.each { |run| s = run[-1]; s << "?" }
p last

held = [+"x", +"y", +"z"]
parts = held.slice_after { |s| s == "x" }
parts.each { |run| run[0] << "+" }
p held

swapped = [+"x", +"y", +"z"]
swapped.slice_before { |s| s == "y" }.each { |run| run[0] = +"q" }
p swapped

pattern = [+"x", +"y", +"z"]
pattern.slice_after("y").to_a.each { |run| run[-1] << "!" }
p pattern
