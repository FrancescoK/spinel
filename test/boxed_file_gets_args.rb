# gets and readline on an IO handle read out of a container (a File, a pipe
# reader) take the separator, limit and `chomp:` arguments a typed File takes.
path = "/tmp/sp_boxed_file_gets_args_#{Process.pid}.txt"
File.write(path, "hello\nworld\nend")
def fresh(path) = [File.open(path), 0][0]

f = fresh(path); p f.gets("o"); p f.gets("o"); f.close
f = fresh(path); p f.gets(3); p f.gets(3); f.close
f = fresh(path); p f.gets(chomp: true); p f.gets(chomp: true); f.close
f = fresh(path); p f.gets("l", 2); p f.gets(4, chomp: true); p f.gets(nil); f.close
f = fresh(path); p f.readline("r"); p f.readline(2); p f.readline(chomp: true); f.close

sep = "l"
lines = []
f = fresh(path)
while (l = f.gets(sep, chomp: true)); lines << l; end
f.close
p lines

# the handle a call answers, held nowhere else, across a separator that
# allocates
p fresh(path).gets("#{sep}o#{("q" * 3000).clear}")

r, w = IO.pipe
x = [r, 0][0]
w.write("ab\ncd"); w.close
p x.gets("b"); p x.gets(chomp: true); p x.readline(1)
x.close

# at end of file gets answers nil and readline raises
f = fresh(path); f.read
p f.gets("o")
e = (f.readline("o") rescue $!.class)
p e
f.close
File.delete(path)
