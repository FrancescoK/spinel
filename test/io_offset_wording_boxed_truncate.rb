# An IO offset converts with NUM2OFFT, which words a nil "from nil", a
# String "from string" and true or false "from boolean". A boxed receiver's
# truncate converted its argument as a number's precision before it knew the
# receiver was an IO, and the typed offset slots worded a String and a
# boolean as rb_num2long does. A number's truncate keeps NUM2LONG's wording.

require "tmpdir"

def t(k)
  path = File.join(Dir.tmpdir, "spinel_io_offset_wording_#{Process.pid}.txt")
  f = File.open(path, "w")
  [-> { [f, 1][k].truncate(nil) }, -> { [f, 1][k].truncate("a") }, -> { [f, 1][k].truncate(0) },
   -> { [1.5, f][k].truncate(nil) }, -> { [7, f][k].truncate(nil) }, -> { [1.25, f][k].truncate(1) },
   -> { f.truncate("a") }, -> { f.seek("a") }, -> { f.pos = "a" }, -> { f.truncate(true) },
   -> { f.seek([false, 1][k]) }, -> { f.seek([+"a", 1][k]) }, -> { f.truncate(:s) }, -> { 1.truncate("a") }].each do |l|
    p l.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  f.close
  File.delete(path)
end
t(ARGV.size)
