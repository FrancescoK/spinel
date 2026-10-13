# A String the rule shares, marked to be handed over as its handle where a
# call by its name could reach a program method (two classes define write),
# is read as its String where a builtin takes its bytes: File.write's path
# here. The operand was refused (#8328, a Rails application's
# File.write(PATH, key)).
require "tmpdir"

PATH = File.join(Dir.tmpdir, +"flipsop_#{Process.pid}")
PATH << ".txt"

class Stream
  def initialize
    @chunks = []
  end

  def write(s)
    @chunks << s
    s.length
  end

  def chunks = @chunks
end

class Sink
  def write(s) = s.size
end

out = Stream.new
out.write(PATH)
p out.chunks[0].equal?(PATH), Sink.new.write("ab")
PATH << ".bak"
File.write(PATH, "k")
p File.basename(PATH).end_with?(".bak"), out.chunks[0].end_with?(".bak")
File.delete(PATH)
