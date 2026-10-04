root = "/tmp/spinel_dir_entries_t_#{Process.pid}"
Dir.mkdir(root) unless Dir.exist?(root)
File.write("#{root}/b.txt", "x")
File.write("#{root}/a.txt", "x")
File.write("#{root}/.hidden", "x")
puts Dir.entries(root).sort.inspect
puts Dir.children(root).sort.inspect
begin
  Dir.entries("#{root}/nope")
rescue => e
  puts "raised: #{e.message.sub("_#{Process.pid}", "")}"   # the path, without this run's own tag
end
File.delete("#{root}/a.txt"); File.delete("#{root}/b.txt"); File.delete("#{root}/.hidden")
Dir.rmdir(root)
