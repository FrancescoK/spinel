require "strscan"

class Foo
  def bar; end
end

obj = Foo.new
[:bar, "bar", :nope, 1, nil].each do |n|
  begin
    p obj.respond_to?(n)
  rescue TypeError => e
    puts "TypeError: #{e.message}"
  end
end

s = StringScanner.new("abc")
[:scan, "eos?", :pos, :nope].each { |n| p s.respond_to?(n) }
