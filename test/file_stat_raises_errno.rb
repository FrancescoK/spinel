# File.stat and File.lstat raise the error their errno names, with its
# message, as CRuby does, where they always raised Errno::ENOENT.
path = "/tmp/spinel_stat_errno_#{Process.pid}"
File.write(path, "hello")
def t(l)
  r = yield
  puts "#{l} => #{r.inspect}"
rescue SystemCallError => e
  puts "#{l} => #{e.class}: #{e.message.sub(/ - .*/, "")}"
end
t("stat enotdir") { File.stat(path + "/x").size }
t("lstat enotdir") { File.lstat(path + "/x").size }
t("stat toolong") { File.stat("/tmp/" + "a" * 5000).size }
t("stat enoent") { File.stat(path + "_missing").size }
t("lstat enoent") { File.lstat(path + "_missing").size }
loop_path = path + "_loop"
File.symlink(loop_path, loop_path)
t("stat eloop") { File.stat(loop_path).size }
t("stat ok") { File.stat(path).size }
File.delete(loop_path)
File.delete(path)
