# Each readline result is a new String even when its container shares it.
require "stringio"
io = StringIO.new("ab\ncd\nef\ngh\n")
values = [io.readline, io.readline(2), io.readline(chomp: true), io.readline(nil, chomp: true)]
values.each { |value| value << "!" }
p values
p io.string
