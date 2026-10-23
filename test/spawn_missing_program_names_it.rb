# A one-String command line that cannot run raises Errno::ENOENT naming its
# program: the name pointed into the split words, freed before the message
# was made (CodeRabbit on #10010).
begin
  Process.spawn("spinel_missing_cmd_xyz arg")
rescue SystemCallError => e
  p e.class
  puts e.message
end
begin
  exec("spinel_missing_cmd_xyz arg")
rescue SystemCallError => e
  p e.class
  puts e.message
end
