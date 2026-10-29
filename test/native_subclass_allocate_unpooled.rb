# A StringIO extended with a module is a singleton link below a native
# class, which is allocated with the native finalizer and has no pool. The
# Class#allocate switch allocated it through the pool macro all the same and
# named pool counters nothing declares; with threads in the program, clang's
# recovery then applied an atomic builtin to the gc_scan function it took
# the name for. It is allocated as its constructor allocates it.
require "stringio"
require "base64"

module XmlMini
  extend self

  module FileLike # :nodoc:
    attr_writer :original_filename, :content_type

    def original_filename
      @original_filename || "untitled"
    end

    def content_type
      @content_type || "application/octet-stream"
    end
  end

  def _parse_file(file, entity)
    f = StringIO.new(::Base64.decode64(file))
    f.extend(FileLike)
    f.original_filename = entity["name"]
    f.content_type = entity["content_type"]
    f
  end
end

f = XmlMini._parse_file(Base64.encode64("hello"), { "name" => "a.txt" })
puts f.original_filename, f.content_type, f.read

class Point
  attr_accessor :x
end
klass = [Point, XmlMini].first
o = klass.allocate
o.x = 3
p o.x, o.class

t = Thread.new { 1 + 1 }
p t.value
