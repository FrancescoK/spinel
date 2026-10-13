# A green thread runs on a fixed C stack. Running past it used to die in
# whatever sat below the stack's one guard page, with nothing naming the
# stack; the guard is now sized to the largest frame a build is likely to
# emit (#4496), and a fault inside it raises SystemStackError in the thread,
# which #value raises again here, uncaught.
def deep(n)
  a = [n, n + 1, n + 2, n + 3]
  return a.sum if n == 0
  deep(n - 1) + a[1]
end
t = Thread.new { deep(10_000_000) }
p t.value
