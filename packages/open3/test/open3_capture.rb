require "open3"
out, err, st = Open3.capture3("sh", "-c", "echo out; echo err 1>&2; exit 3")
p out, err, st.exitstatus, st.success?
out, st = Open3.capture2("cat", stdin_data: "fed in\n")
p out, st.success?
out, st = Open3.capture2e("sh -c 'echo a; echo b 1>&2'")
p out.lines.sort, st.exitstatus
begin
  Open3.capture3("definitely-not-a-command-xyz")
rescue SystemCallError => e
  puts e.class
end
out, st = Open3.capture2("sh", "-c", "cat; echo more", stdin_data: "in\n")
p out
# no stdin_data: the child reads EOF, not the parent's input
out, st = Open3.capture2("cat")
p out
begin
  Open3.capture2e("definitely-not-a-command-xyz")
rescue SystemCallError => e
  puts e.class
end
