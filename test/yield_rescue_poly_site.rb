# A yield whose value leaves through a rescue frame takes each call site's
# own block value, a poly one included, and the rescue arm's when the block
# raises (#5994).
def guarded
  yield
rescue StandardError
  "rescued"
end

puts guarded { "plain" }
puts guarded { ARGV.empty? ? "big" : :small }
p guarded { 42 }
p guarded { raise "boom" }

def fenced(x)
  begin
    yield x
  rescue ArgumentError => e
    e.message
  end
end

p fenced(2) { |v| v * 10 }
p fenced("s") { |v| v + "!" }
p fenced(0) { |v| raise ArgumentError, "bad #{v}" }
