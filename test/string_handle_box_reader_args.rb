# A new String put into a container is the String object under
# --share-strings (boxed as its handle), and a builtin read off the
# container takes it as the String it is: Integer(), Float(), Rational(),
# Complex(), to_r, to_c, format, %, Encoding.find, force_encoding, encode,
# strftime, ENV, IO#ungetc, File.delete, Array#to_h. The same in both
# builds.
require "tmpdir"
def pick(v) = v
k = pick(1) == 1 ? "" : 1.to_s
x = [k + "ab", 1].first
p format("%s %p %-4s|", x, x, x)
p "#{x}#{x}", x * 2, x + x, x % []
p [x, x].join("-"), [x, 1].join, x.center(6, "*"), x.ljust(4, x)
p Integer([k + "12", 1].first), Float([k + "1.5", 1].first), Rational([k + "1/3", 1].first), Complex([k + "1+2i", 1].first)
p [k + "3", 1].first.to_r, [k + "3", 1].first.to_c
p x.encoding, x.force_encoding([k + "BINARY", 1].first).encoding
y = [k + "hé", 1].first
p y.encode([k + "UTF-8", 1].first).bytesize
p Encoding.find([k + "utf-8", 1].first)
p Time.at(0).utc.strftime([k + "%Y", 1].first)
p ENV.fetch([k + "SPINEL_HANDLE_READER_NOPE", 1].first, "dflt")
ENV[[k + "SPINEL_HANDLE_READER_Y", 1].first] = [k + "vv", 1].first
p ENV["SPINEL_HANDLE_READER_Y"]
p [[k + "a", 1]].to_h, [[1, k + "v"]].to_h
path = File.join(Dir.tmpdir, "spinel_handle_reader_#{Process.pid}.txt")
File.write(path, "x")
File.open(path) { |io| p io.ungetc([k + "Q", 1].first), io.getc }
p File.delete(*[[k + path, 1].first]), File.exist?(path)
