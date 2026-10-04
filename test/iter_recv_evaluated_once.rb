# A fused loop must evaluate its receiver expression once, not once per
# iteration: re-running a call mid-loop re-reads whatever it returns, so
# `Dir.children(dir).each` deleting entries used to skip half of them.
$n = 0
def src
  $n += 1
  [1, 2, 3]
end

def chk(label)
  $n = 0
  yield
  puts "#{label} #{$n}"
end

chk("each") { src.each { |x| x } }
chk("each_with_index") { src.each_with_index { |x, i| x } }
chk("reverse_each") { src.reverse_each { |x| x } }
chk("zip") { src.zip(src) { |a, b| a } }
chk("map") { src.map { |x| x } }
chk("select") { src.select { |x| x > 1 } }
chk("each_slice") { src.each_slice(2) { |a| a } }
chk("each_cons") { src.each_cons(2) { |a| a } }

# a directory listing is a snapshot: deleting inside the block still visits
# every entry the call returned
root = "/tmp/spinel_iter_recv_once_t_#{Process.pid}"
Dir.mkdir(root) unless Dir.exist?(root)
File.write("#{root}/a.txt", "a")
File.write("#{root}/b.txt", "b")
File.write("#{root}/c.txt", "c")
visited = []
Dir.children(root).each do |name|
  visited << name
  File.delete("#{root}/#{name}")
end
puts visited.sort.inspect
puts Dir.children(root).sort.inspect
Dir.rmdir(root)
