# spinel: share
# spinel: gc-minor
# Typed nil separators raise before partition creates or exposes any pieces.
reader, writer = IO.pipe
writer.close
separator = reader.gets
reader.close
begin
  pieces = "a-b".partition(separator)
  pieces[1] << "!"
  p [pieces, separator]
rescue TypeError => e
  p [e.class, e.message]
end
begin
  pieces = "a-b".rpartition(separator)
  pieces[1] << "!"
  p [pieces, separator]
rescue TypeError => e
  p [e.class, e.message]
end
# An out-of-bounds typed String element has the same nil representation.
missing = ["-"][ARGV.size + 1]
begin
  p "a-b".partition(missing)
rescue TypeError => e
  p [e.class, e.message]
end
begin
  p "a-b".rpartition(missing)
rescue TypeError => e
  p [e.class, e.message]
end
# Empty and matching String separators remain valid in either direction.
p "a-b".partition("")
p "a-b".rpartition("")
p "a-b".partition("-")
p "a-b".rpartition("-")
