# A backtick command line with no shell character runs as its words, with
# no shell: a program that cannot run raises its Errno, as under CRuby.
begin
  p `spinel_missing_q1`
rescue SystemCallError => e
  p e.class, e.message
end
begin
  `spinel_missing_q1 a b`
rescue Errno::ENOENT => e
  p e.message
end
p $?.exitstatus
p $?.pid > 0
p `spinel_missing_q1 2>/dev/null`
p $?.exitstatus
begin
  `   `
rescue Errno::ENOENT => e
  p e.message
end
p `echo  a   b`
p $?.success?
begin
  `/`
rescue SystemCallError => e
  p e.class, e.message
end
cmd = "echo"
p `#{cmd} interp`
p %x(echo hi)
p `sh -c 'exit 4'`
p $?.exitstatus
p `false`
p $?.exitstatus
