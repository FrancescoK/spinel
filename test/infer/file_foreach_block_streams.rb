# File.foreach's block form streams: no readlines in the emitted C (infer-test).
path = "/tmp/sp_infer_file_foreach_block_streams.txt"
File.write(path, "a\nbb\n")
n = 0
File.foreach(path) { |l| n += l.size }
File.foreach(path, chomp: true) { |l| n += l.size }
File.foreach(path, "b", 1) { |l| n += l.size }
p n
File.delete(path)
