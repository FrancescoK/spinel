# A `next` in an IO loop's block (each_line, each_char) inside a
# begin..ensure leaves that iteration only. It was compiled as leaving the
# protected region: the loop stopped at the first `rescue next`.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_next_in_io_loop_#{Process.pid}.txt")
File.write(path, "1\nbad\n3\n")

out = []
File.open(path) do |io|
  begin
    io.each_line do |line|
      e = Integer(line) rescue next
      out << e
    end
    out << 99
  ensure
    out << :ensure
  end
end
p out

def run
  begin
    yield
  ensure
    puts "run ensure"
  end
end
out = []
File.open(path) do |io|
  run do
    io.each_line do |line|
      next if line.start_with?("b")
      out << line.chomp
    end
    out << :after
  end
end
p out

# break and an early return from inside the loop, under the ensure
def first_bad(path)
  File.open(path) do |io|
    begin
      io.each_line { |line| return line.chomp unless line =~ /\A\d/ }
      nil
    ensure
      puts "first_bad ensure"
    end
  end
end
p first_bad(path)

seen = []
File.open(path) do |io|
  begin
    io.each_line do |line|
      break if line.start_with?("3")
      seen << line.chomp
    end
  ensure
    seen << :ensure
  end
end
p seen

chars = []
File.open(path) do |io|
  begin
    io.each_char do |ch|
      next if ch == "\n"
      chars << ch
    end
  ensure
    chars << :ensure
  end
end
p chars.join(",")
File.delete(path)
