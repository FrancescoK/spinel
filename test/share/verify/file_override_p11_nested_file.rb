module Foo
  class File
    def self.exist?(x) = "foo:#{x}"
  end
  def self.t = File.exist?("/")
end
p File.exist?("/")
p Foo.t
p Foo::File.exist?("/")
p ::File.exist?("/")
