# IO::EWOULDBLOCKWaitReadable / Writable are IO::EAGAINWaitReadable /
# Writable where Errno::EWOULDBLOCK is Errno::EAGAIN (Linux, macOS): CRuby
# defines them from the errno classes, so the pairs are one class each.
p IO::EAGAINWaitReadable.equal?(IO::EWOULDBLOCKWaitReadable) == Errno::EAGAIN.equal?(Errno::EWOULDBLOCK)
p IO::EAGAINWaitWritable.equal?(IO::EWOULDBLOCKWaitWritable) == Errno::EAGAIN.equal?(Errno::EWOULDBLOCK)
begin
  raise IO::EWOULDBLOCKWaitReadable, "x"
rescue IO::EAGAINWaitReadable => e
  p e.message
end
