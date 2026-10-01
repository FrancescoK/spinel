def ruby_bug(bug, req = nil)
  p [bug, req, req.nil?]
  p(req || "none")
  yield if block_given?
end
ruby_bug "#1", ""..."4.1"
ruby_bug("#2") { p :blk }

def span(r = nil) = r ? r.to_a.size : -1
p span(1..4)
p span

def fspan(r = nil) = p(r)
fspan(1.5..2.5)
fspan
