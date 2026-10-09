r, w = IO.pipe
p [r.respond_to?(:winsize), r.respond_to?(:winsize=)]
p %i[winsize winsize=].map { |m| $stdout.respond_to?(m) }
r.close
w.close
