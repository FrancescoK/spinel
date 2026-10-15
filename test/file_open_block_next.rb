require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_file_next_#{Process.pid}")
File.write(path, "abc")
take_next = ARGV.empty?

p File.open(path) { |f| next 7 if take_next; f.size }
p File.open(path) { |f| next 7 unless take_next; f.size }
p File.open(path) { |f| next if take_next; f.size }
p File.open(path) { |f| next "done" if take_next; f.size }
p File.open(path) { next :last }

out = []
saved = nil
2.times do |i|
  value = File.open(path) do |f|
    saved = f
    begin
      next i + 10 if take_next
    ensure
      out << :ensure
    end
    0
  end
  out << value
  out << saved.closed?
end
p out

pr = proc do
  value = File.open(path) { next 4 if take_next; 0 }
  value + 1
end
p pr.call

p File.open(path) { [1, 2].each { |n| next if n == 1 }; 9 }
p File.open(path) { |f| break 6 if take_next; f.size }

3.times do |i|
  value = File.open(path) do
    begin
      next "result#{i}" if take_next
    ensure
      GC.start
      20.times { |j| "garbage#{j}" * 10 }
    end
    "fallback"
  end
  p value
end
File.delete(path)
