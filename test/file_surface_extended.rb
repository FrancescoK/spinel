File.write("/tmp/sp_f2_#{Process.pid}", "hello world")
p File.ftype("/tmp/sp_f2_#{Process.pid}")
Dir.mkdir("/tmp/sp_f2dir_#{Process.pid}") unless Dir.exist?("/tmp/sp_f2dir_#{Process.pid}")
p File.ftype("/tmp/sp_f2dir_#{Process.pid}")
p((File.ftype("/nonex") rescue $!.class))
p File.writable?("/tmp/sp_f2_#{Process.pid}")
p File.executable?("/tmp/sp_f2_#{Process.pid}")
p File.size?("/tmp/sp_f2_#{Process.pid}")
p File.size?("/nonex")
File.write("/tmp/sp_f0_#{Process.pid}", "")
p File.size?("/tmp/sp_f0_#{Process.pid}")
p File.pipe?("/tmp/sp_f2_#{Process.pid}")
p File.identical?("/tmp/sp_f2_#{Process.pid}", "/tmp/sp_f2_#{Process.pid}")
p File.identical?("/tmp/sp_f2_#{Process.pid}", "/tmp/sp_f2dir_#{Process.pid}")
p File.atime("/tmp/sp_f2_#{Process.pid}").class
p File.ctime("/tmp/sp_f2_#{Process.pid}").class
p File.realpath("/tmp/../tmp/sp_f2_#{Process.pid}") == File.join(File.realpath("/tmp"), "sp_f2_#{Process.pid}")
p File.read("/tmp/sp_f2_#{Process.pid}", 5)
p File.read("/tmp/sp_f2_#{Process.pid}", 500)
p File.chmod(0644, "/tmp/sp_f2_#{Process.pid}")
p File.truncate("/tmp/sp_f2_#{Process.pid}", 5)
p File.read("/tmp/sp_f2_#{Process.pid}")
File.write("/tmp/sp_f2_#{Process.pid}", "hello")
File.write("/tmp/sp_f2_#{Process.pid}", "XY", 1)
p File.read("/tmp/sp_f2_#{Process.pid}")
p File.write("/tmp/sp_f2_#{Process.pid}", "AB", mode: "a")
p File.read("/tmp/sp_f2_#{Process.pid}")
File.foreach("/tmp/sp_f2_#{Process.pid}") { |line| p line }
p File.split("/a/b/c.rb")
p File.absolute_path("c.rb", "/a/b")
p File.path("/a/b")
p File.fnmatch("*.rb", "c.rb")
p File.fnmatch("a*", "bc")
p File.fnmatch?("*.rb", "x.rb")
f = File.new("/tmp/sp_f2_#{Process.pid}")
p f.read
f.close
f2 = File.open("/tmp/sp_f2_#{Process.pid}")
p f2.size
p f2.mtime.class
p f2.chmod(0644)
f2.close
st = File.stat("/tmp/sp_f2_#{Process.pid}")
p st.size
p st.mtime.class
p001 = "/tmp/sp_bug_open_intmode_#{Process.pid}"
File.open(p001, File::WRONLY | File::CREAT | File::TRUNC) { |f| f.write("x") }
p File.read(p001)
File.delete(p001)
r001 = (begin; File.open("/tmp/sp_modekw_#{Process.pid}", mode: "w") { |f| f.write("x") }; File.read("/tmp/sp_modekw_#{Process.pid}"); rescue => e001; e001.class; end)
p r001
File.delete("/tmp/sp_modekw_#{Process.pid}") if File.exist?("/tmp/sp_modekw_#{Process.pid}")
p FileTest.exist?("/tmp/sp_f2_#{Process.pid}")
p FileTest.file?("/tmp/sp_f2_#{Process.pid}")
p FileTest.directory?("/tmp/sp_f2dir_#{Process.pid}")
p File.dirname("/a/b/c", 2)
p File.dirname("a/b/c/d", 3)
p File.dirname("/a", 5)
File.delete("/tmp/sp_f2_#{Process.pid}", "/tmp/sp_f0_#{Process.pid}")
Dir.rmdir("/tmp/sp_f2dir_#{Process.pid}")
puts "done"
