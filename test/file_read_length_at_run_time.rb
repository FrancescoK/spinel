# File.read and File.binread with a length, or a length and an offset:
# a length that is nil only at run time reads the rest of the file, a
# directory raises Errno::EISDIR, and the arguments are evaluated in source
# order, as in CRuby.
require "tmpdir"

$order = []
def note(name, value) = ($order << name; value)
def no_length = ($order << :no_length; nil)

Dir.mktmpdir do |dir|
  path = File.join(dir, "data")
  File.write(path, "0123456789")
  [true, false].each do |whole|
    length = whole ? nil : 4
    p File.read(path, length)
    p File.read(path, length, 3)
    p File.binread(path, length, 3).encoding
  end

  [-> { File.read(dir, 4) }, -> { File.read(dir, 4, 0) }, -> { File.read(dir, nil, 0) },
   -> { File.binread(dir, 4) }].each do |call|
    p(begin
        call.call
      rescue SystemCallError => e
        e.class
      end)
  end

  File.read(note(:path, path), note(:length, 2), note(:offset, 1))
  File.read(note(:path, path), note(:length, nil), note(:offset, 1))
  File.read(note(:path, path), note(:length, nil))
  File.read(note(:path, path), no_length, note(:offset, 1))
  p $order
end
