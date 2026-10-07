# Dir.entries and Dir.children given the encoding keyword, and the foreach
# and each_child forms that read through them. Find.find lists a directory
# as Dir.children(path, encoding: Encoding.find("filesystem")).

def listing(root)
  p Dir.children(root, encoding: "UTF-8").sort
  p Dir.entries(root, encoding: Encoding::UTF_8).sort
  p Dir.children(root, encoding: Encoding.find("filesystem")).sort
  p Dir.children(root, encoding: nil).sort
  names = []
  Dir.each_child(root, encoding: "UTF-8") { |n| names << n }
  p names.sort
  names = []
  Dir.foreach(root, encoding: "UTF-8") { |n| names << n }
  p names.sort
  p Dir.each_child(root, encoding: "UTF-8").to_a.sort
end

def tags(root)
  p Dir.children(root, encoding: "BINARY").map(&:encoding).uniq
  p Dir.children(root, encoding: "ascii-8bit").map(&:encoding).uniq
  p Dir.children(root, encoding: "UTF-8").map(&:encoding).uniq
end

def refused(root, enc)
  Dir.children(root, encoding: enc)
rescue => e
  puts "#{e.class}: #{e.message}"
end

root = "/tmp/spinel_dir_encoding_t_#{Process.pid}"
Dir.mkdir(root) unless Dir.exist?(root)
File.write("#{root}/a.txt", "x")
File.write("#{root}/.hidden", "x")
listing(root)
tags(root)
refused(root, "nope")
refused(root, 1)
refused(root, :binary)
refused("#{root}/missing", "nope")   # the name is checked before the directory is opened
File.delete("#{root}/a.txt"); File.delete("#{root}/.hidden")
Dir.rmdir(root)
