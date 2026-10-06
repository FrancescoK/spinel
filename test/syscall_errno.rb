# A filesystem call that fails raises the Errno exception CRuby raises, with
# CRuby's message, instead of answering -1, 0, nil or a success count:
# Dir.mkdir / rmdir / delete / unlink / chdir, File.delete / unlink / rename /
# truncate, and the Pathname methods built on them. The metadata readers
# (File.size, atime, mtime, ctime, birthtime) name CRuby's entry point in
# their message too.

require "pathname"

# The scratch paths carry the process id, so that two runs at once do not
# share them; the lines printed name them without it.
def try(label)
  r = yield
  puts "#{label} => #{r.inspect.gsub("_#{Process.pid}", "")}"
rescue SystemCallError, TypeError => e
  puts "#{label}: #{e.class}: #{e.message.gsub("_#{Process.pid}", "")}"
end

def second_path(base)
  puts "second path evaluated"
  "#{base}/also-missing"
end

base = "/tmp/sp_syscall_errno_#{Process.pid}"
# a previous run that died midway leaves its files behind: clear them first
Pathname.new(base).rmtree if Dir.exist?(base)
Dir.mkdir(base)
missing = "#{base}/missing"
file = "#{base}/file.txt"
File.write(file, "abc")
sub = "#{base}/sub"
Dir.mkdir(sub) unless Dir.exist?(sub)
File.write("#{sub}/inner", "")

puts "--- Dir"
try("mkdir existing") { Dir.mkdir(base) }
try("mkdir under a missing parent") { Dir.mkdir("#{missing}/child") }
try("mkdir") { Dir.mkdir("#{base}/fresh") }
try("rmdir") { Dir.rmdir("#{base}/fresh") }
try("rmdir missing") { Dir.rmdir(missing) }
try("rmdir non-empty") { Dir.rmdir(sub) }
try("rmdir a file") { Dir.rmdir(file) }
try("delete missing") { Dir.delete(missing) }
try("unlink missing") { Dir.unlink(missing) }
try("chdir missing") { Dir.chdir(missing) }
try("chdir a file") { Dir.chdir(file) }

puts "--- File"
try("delete missing") { File.delete(missing) }
try("unlink missing") { File.unlink(missing) }
try("delete") { File.delete(file) }
try("delete two, second missing") { File.write(file, "abc"); File.delete(file, missing) }
try("deleted the first before raising") { File.exist?(file) }
try("delete two, first missing") { File.delete(missing, second_path(base)) }
try("delete two, nil second") { File.write(file, "abc"); File.delete(file, { "a" => "b" }["zz"]) }
try("the first survives a nil later in the list") { File.exist?(file) }
try("rename missing") { File.rename(missing, file) }
try("rename into a missing directory") { File.write(file, "abc"); File.rename(file, "#{missing}/x") }
try("rename") { File.rename(file, "#{file}.moved") }
try("rename back") { File.rename("#{file}.moved", file) }
try("truncate negative") { File.truncate(file, -1) }
try("truncate missing") { File.truncate(missing, 0) }
try("truncate") { File.truncate(file, 1) }
try("size missing") { File.size(missing) }
try("atime missing") { File.atime(missing) }
try("mtime missing") { File.mtime(missing) }
try("ctime missing") { File.ctime(missing) }
try("birthtime missing") { File.birthtime(missing) }

puts "--- errnos with a class of their own"
try("mkdir name too long") { Dir.mkdir("#{base}/" + "a" * 300) }
File.symlink("#{base}/loop", "#{base}/loop")
try("chdir symlink loop") { Dir.chdir("#{base}/loop") }
try("delete through a symlink loop") { File.delete("#{base}/loop/x") }
File.delete("#{base}/loop")

puts "--- a nil path"
h = { "a" => "b" }
x = h["zz"]
try("mkdir nil") { Dir.mkdir(x) }
try("rmdir nil") { Dir.rmdir(x) }
try("chdir nil") { Dir.chdir(x) }
try("delete nil") { File.delete(x) }
try("rename nil") { File.rename(x, x) }
try("truncate nil") { File.truncate(x, 0) }

puts "--- a failing call inside Dir.chdir's block"
here = Dir.pwd
begin
  Dir.chdir(base) { File.delete(missing) }
rescue SystemCallError => e
  puts "inside the block: #{e.class}"
end
puts "cwd restored: #{Dir.pwd == here}"
try("chdir block into a missing directory") { Dir.chdir(missing) { :never } }
r = Dir.chdir(base) { Dir.chdir(sub) { File.basename(Dir.pwd) } }
puts "nested chdir blocks answer #{r} and restore: #{Dir.pwd == here}"

puts "--- rescue shapes"
begin
  Dir.rmdir(missing)
rescue Errno::ENOENT => e
  puts "Errno::ENOENT caught: #{e.message.gsub("_#{Process.pid}", "")}"
end
begin
  File.delete(missing)
rescue => e
  puts [e.is_a?(SystemCallError), e.is_a?(StandardError), e.class].inspect
end
result = begin
  Dir.mkdir(base)
rescue Errno::EEXIST
  :already_there
end
p result

puts "--- Pathname"
pn = Pathname.new(missing)
try("rmdir") { pn.rmdir }
try("delete") { pn.delete }
try("unlink") { pn.unlink }
try("rename") { pn.rename("#{base}/elsewhere") }
try("size") { pn.size }
try("mkdir existing") { Pathname.new(sub).mkdir }
try("mkdir") { Pathname.new("#{base}/made").mkdir }
try("rmdir made") { Pathname.new("#{base}/made").rmdir }

puts "--- Pathname#rmtree and #mkpath"
try("rmtree missing") { Pathname.new(missing).rmtree }
try("rmtree answers its receiver") { pn = Pathname.new(missing); pn.rmtree.equal?(pn) }
try("rmtree_entry is not public") { Pathname.new(missing).respond_to?(:rmtree_entry) }
try("rmtree deep missing") { Pathname.new("#{missing}/deeper").rmtree }
Dir.mkdir("#{base}/tree")
Dir.mkdir("#{base}/tree/in")
File.write("#{base}/tree/in/f", "x")
File.write("#{base}/tree/g", "y")
try("rmtree a tree") { [Pathname.new("#{base}/tree").rmtree.class, Dir.exist?("#{base}/tree")] }
try("mkpath") { [Pathname.new("#{base}/a/b/c").mkpath.class, Dir.exist?("#{base}/a/b/c")] }
try("mkpath again") { Pathname.new("#{base}/a/b/c").mkpath.class }
try("mkpath through a file") { Pathname.new("#{file}/x").mkpath }
try("rmtree cleans up") { [Pathname.new("#{base}/a").rmtree.class, Dir.exist?("#{base}/a")] }
deep = "#{base}/deep"
Dir.mkdir(deep)
d = deep
120.times { |i| d = "#{d}/l#{i}"; Dir.mkdir(d); File.write("#{d}/f", "x") }
try("rmtree a tree 120 deep") { [Pathname.new(deep).rmtree.class, Dir.exist?(deep)] }

File.delete("#{sub}/inner")
Dir.rmdir(sub)
File.delete(file)
Dir.rmdir(base)
p Dir.exist?(base)
