# Process.detach answers a thread that reaps the child, whose value is the
# child's Process::Status (#7203).
pid = Process.spawn("sh", "-c", "exit 3")
t = Process.detach(pid)
st = t.value
p st.exitstatus
p st.pid == pid
p t.is_a?(Thread)
