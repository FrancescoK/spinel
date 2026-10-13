out = IO.popen(["printf", "a\\0b"], "rb", &:read)
p out, out.bytesize, $?.success?
p IO.popen(["sh", "-c", "echo hi; exit 3"]) { |io| io.read }, $?.exitstatus
p IO.popen("echo one two") { |io| io.read.split }
p IO.popen(["sh", "-c", "echo err >&2; echo out"], err: File::NULL, &:read)
begin
  IO.popen(["definitely-not-a-command-xyz"], &:read)
rescue SystemCallError => e
  p e.class
end
