path = "/tmp/spinel_issue_2985_#{Process.pid}.txt"
File.write(path, "hello")
t = File.birthtime(path)
puts t.class
puts t.is_a?(Time)
File.delete(path)
