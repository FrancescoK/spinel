# IO instance reads: gets separator/limit/chomp, readline EOFError, lineno,
# getc/readchar/getbyte, each_line separator + fresh strings, printf/putc,
# pos=, readpartial, flock, each_char/each_byte, multi-arg write, sysseek.
File.write("/tmp/sp_io3_#{Process.pid}.txt", "hello\nworld\n")
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.gets("o") }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.gets(3) }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.gets(chomp: true) }
File.open("/tmp/sp_io3_#{Process.pid}.txt") do |f|
  f.read
  r = (f.readline rescue $!.class)
  p r
end
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| f.gets; p f.lineno }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.getc }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.readchar }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.getbyte }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| f.each_line("o") { |l| p l } }
File.write("/tmp/sp_io3b_#{Process.pid}.txt", "one\ntwo\nthree\n")
File.open("/tmp/sp_io3b_#{Process.pid}.txt") do |f|
  lines = []
  f.each_line { |l| lines << l }
  p lines
end
File.open("/tmp/sp_io3_#{Process.pid}.txt", "w") { |f| f.printf("%03d-%s", 7, "x") }
p File.read("/tmp/sp_io3_#{Process.pid}.txt")
File.open("/tmp/sp_io3_#{Process.pid}.txt", "w") { |f| p f.putc(65); f.putc("bc") }
p File.read("/tmp/sp_io3_#{Process.pid}.txt")
File.write("/tmp/sp_io3_#{Process.pid}.txt", "hello")
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| f.pos = 2; p f.read }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.readpartial(3) }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.flock(File::LOCK_EX) }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| cs = []; f.each_char { |ch| cs << ch }; p cs }
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| bs = []; f.each_byte { |bb| bs << bb }; p bs }
File.open("/tmp/sp_io3_#{Process.pid}.txt", "w") { |f| p f.write("a", "b", "c") }
p File.read("/tmp/sp_io3_#{Process.pid}.txt")
File.open("/tmp/sp_io3_#{Process.pid}.txt") { |f| p f.sysseek(2) }
File.delete("/tmp/sp_io3_#{Process.pid}.txt", "/tmp/sp_io3b_#{Process.pid}.txt")
