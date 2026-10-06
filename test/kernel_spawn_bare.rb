# Kernel#spawn is Process.spawn, and Process.wait reaps it and sets $?
# (#7203).
pid = spawn("echo hi")
Process.wait(pid)
p $?.success?
pid = spawn("printf", "%s|%s\n", "a", "b")
p Process.waitpid(pid) == pid
p $?.exitstatus
