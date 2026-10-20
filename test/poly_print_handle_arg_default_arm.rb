require "zlib"
require "tmpdir"

# A boxed receiver's print, whose arms are a GzipWriter's, an IO's and the
# builtin default's, given a String the dispatch holds as its shared handle:
# each arm prints that String's text.

class Term
  def initialize(output:) = (@output = output)
  def hide = @output.print("[hide]\n")
  def show(notes) = @output.print("[#{notes.join(' ')}]\n")
  def line(text) = @output.print(text)
end

s = +"hello"
notes = [s]
s << "!"
path = File.join(Dir.tmpdir, "spinel_poly_print_handle_arg_#{Process.pid}.gz")
outs = [$stdout, Zlib::GzipWriter.new(File.open(path, "wb")), Object.new]
t = +"line\n"
u = t
u << "more\n"
2.times do |i|
  term = Term.new(output: outs[i])
  term.hide
  term.show(notes)
  term.line(t)
end
outs[1].close
p Zlib::GzipReader.open(path, &:read)
begin
  Term.new(output: outs[2]).show(notes)
rescue NoMethodError => e
  p e.class
end
File.delete(path)
