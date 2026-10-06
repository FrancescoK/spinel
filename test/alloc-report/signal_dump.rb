# A program that never exits, which is the case the atexit dump cannot serve:
# a server is killed rather than returned from. The Makefile signals this one
# twice and then kills it with SIGKILL, so a report that exists at the end can
# only have come from a signal -- atexit never ran.
# `ready` tells the Makefile the program runs, so it can signal at once. It is
# printed after the first String, not before the loop: a signal that lands
# right behind `ready` is dumped at the next allocation, and before the first
# one the table holds no String row for the Makefile to find.
i = 0
total = 0
while true
  s = "item-#{i}"
  a = [s, s]
  total += s.length + a.length
  if i == 0
    puts "ready"
    $stdout.flush
  end
  i += 1
end
