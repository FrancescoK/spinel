# IO.popen("ls") in a comment
cmd = 'IO.popen("ls") { |io| io.read }'
doc = "run it with IO.popen"
p cmd.size, doc.end_with?("IO.popen")
p IO.respond_to?(:__sp_popen, true)
