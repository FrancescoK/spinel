# A spawned child holds only the pipe ends its redirections hand it: IO.pipe
# answers close-on-exec ends, as CRuby's are.
r, w = IO.pipe
p [r.close_on_exec?, w.close_on_exec?]

# a child given nothing does not hold the write end. Held, the cases below
# would hang and leave their cat running, so the test stops here instead.
pid = Process.spawn("sh", "-c", "(: >&#{w.fileno}) 2>/dev/null")
_, st = Process.waitpid2(pid)
p st.success?
exit 1 if st.success?

# the parent's close is the child's EOF
out_r, out_w = IO.pipe
pid = Process.spawn("cat", in: r, out: out_w)
r.close
out_w.close
w.write("hi\n")
w.close
p out_r.read
out_r.close
_, st = Process.waitpid2(pid)
p st.success?

# a running child does not hold a pipe it was not given
a_r, a_w = IO.pipe
in_r, in_w = IO.pipe
pid = Process.spawn("cat", in: in_r, out: File::NULL)
in_r.close
a_w.write("x")
a_w.close
p a_r.read
a_r.close
in_w.close
_, st = Process.waitpid2(pid)
p st.success?

# a pipe end that took the free fd 0 still reaches the child as its stdin
IO.for_fd(0).close
r, w = IO.pipe
out_r, out_w = IO.pipe
pid = Process.spawn("cat", in: r, out: out_w)
r.close
out_w.close
w.write("zero\n")
w.close
p out_r.read
out_r.close
_, st = Process.waitpid2(pid)
p st.success?
