# A compact path under a builtin class (`class String::Helper`) keeps its
# leaf as its name. A class of the same leaf in another body is a separate
# class and compiles: only two of them in one body would be one class.

class String::Helper
  def call = "string helper"
end

class Report
  class Helper
    def call = "report helper"
  end
end

module Net
  class Buffer
    def kind = "net buffer"
  end
end

puts String::Helper.new.call
puts Report::Helper.new.call
puts Net::Buffer.new.kind
p IO::Buffer.new(4).size
