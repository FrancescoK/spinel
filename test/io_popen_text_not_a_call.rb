# IO.popen("ls") in a comment
cmd = 'IO.popen("ls") { |io| io.read }'
doc = "run it with IO.popen"
p cmd.size, doc.end_with?("IO.popen")
module Foo
  module IO
    def self.popen(*) = :foo
  end
end
p Foo::IO.popen
p IO.respond_to?(:__sp_popen, true)
