# `IO::Buffer` referenced from a required file, never from the entry file,
# with no `require "io/buffer"` anywhere: CRuby provides IO::Buffer without
# one, and the implicit `require "io/buffer"` splice used to look at the entry
# file's text only, so the required file's IO::Buffer.new compiled and then
# raised NameError (uninitialized constant Buffer) at run time (#6740).
require_relative "io_buffer_from_required_file/uses_io_buffer"

p make_buf.size
p READER.call.size
b = make_buf
b.set_value(:U8, 0, 42)
p b.get_value(:U8, 0)
