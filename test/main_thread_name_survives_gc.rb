# The main thread's name set at run time (a heap String, not a literal)
# survives a collection: g_main_thread is a static struct outside the
# thread registry, so its name has to be marked as its tls map is. A
# literal name hid the bug, since a literal is a static String.
def churn(n)
  a = []
  n.times { |i| a << "y" * (6 + i % 3) }
  a.length
end

Thread.new { 1 }.join
Thread.current.name = "main-" + rand(1).to_s
3.times do
  churn(300000)
  GC.start
end
p Thread.current.name
p Thread.main.name
