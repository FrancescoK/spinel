# The String a builtin read loop yields is rooted for the block that reads it.
# IO#each_line, IO#each_char, Dir#each and ARGF.each_line hand the block a
# freshly allocated String every turn, and held it in nothing but C temporaries
# -- the loop's own, and the block parameter's -- so a block that allocates
# could collect the very string it had just been handed. The loop counts right
# either way; the block reads its yield back as "".
# The last three arms rebind the block parameter, which puts the string the
# block holds in a slot of its own: that one takes a root too.

path = "/tmp/sp_loop_yield_root_#{Process.pid}.txt"
dir  = "/tmp/sp_loop_yield_root_dir_#{Process.pid}"
File.write(path, (1..300).map { |i| "L#{i}" }.join("\n") + "\n")
if Dir.exist?(dir)
  Dir.children(dir).each { |e| File.delete("#{dir}/#{e}") }
  Dir.rmdir(dir)
end
Dir.mkdir(dir)
(1..40).each { |i| File.write("#{dir}/e#{i}.txt", "x") }

# each_line: every line still starts with L after a block that allocates
f = File.open(path)
seen = 0
bad = 0
f.each_line do |l|
  200.times { "q" * 64 }
  seen += 1
  bad += 1 unless l.start_with?("L")
end
f.close
puts "each_line seen=#{seen} bad=#{bad}"

# each_char: every character is still one byte wide
g = File.open(path)
seen2 = 0
bad2 = 0
g.each_char do |ch|
  100.times { "r" * 64 }
  seen2 += 1
  bad2 += 1 if ch.bytesize != 1
end
g.close
puts "each_char seen=#{seen2} bad=#{bad2}"

# Dir#each: every entry is still its own name
d = Dir.open(dir)
seen3 = 0
bad3 = 0
d.each do |e|
  100.times { "s" * 64 }
  seen3 += 1
  bad3 += 1 unless e == "." || e == ".." || e.start_with?("e")
end
d.close
puts "Dir#each seen=#{seen3} bad=#{bad3}"

# ARGF.each_line: the same loop over the files named in ARGV
# (test/loop_yield_root_argf.txt, 200 lines)
seen4 = 0
bad4 = 0
ARGF.each_line do |l|
  100.times { "t" * 64 }
  seen4 += 1
  bad4 += 1 unless l.start_with?("A")
end
puts "ARGF.each_line seen=#{seen4} bad=#{bad4}"

# the same three loops again, with a block that REBINDS its parameter: the
# string it holds is then the block's own, not the one the loop handed it
h = File.open(path)
seen5 = 0
bad5 = 0
h.each_line do |l|
  l = l.upcase
  200.times { "q" * 64 }
  seen5 += 1
  bad5 += 1 unless l.start_with?("L")
end
h.close
puts "each_line rebound seen=#{seen5} bad=#{bad5}"

i = File.open(path)
seen6 = 0
bad6 = 0
i.each_char do |ch|
  ch = ch.upcase
  100.times { "r" * 64 }
  seen6 += 1
  bad6 += 1 if ch.bytesize != 1
end
i.close
puts "each_char rebound seen=#{seen6} bad=#{bad6}"

j = Dir.open(dir)
seen7 = 0
bad7 = 0
j.each do |e|
  e = e.upcase
  100.times { "s" * 64 }
  seen7 += 1
  bad7 += 1 unless e == "." || e == ".." || e.start_with?("E")
end
j.close
puts "Dir#each rebound seen=#{seen7} bad=#{bad7}"

Dir.children(dir).each { |e| File.delete("#{dir}/#{e}") }
Dir.rmdir(dir)
File.delete(path)
