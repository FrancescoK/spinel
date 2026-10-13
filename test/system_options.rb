p system("sh", "-c", "echo hidden; exit 3", out: File::NULL)
p system("true", err: File::NULL)
p system("definitely-not-a-command-xyz", out: File::NULL)
p system("sh", "-c", "test -n \"$1\"", "_", "x",
         err: File::NULL)
begin
  system("sh", "-c", "exit 4", exception: true)
rescue RuntimeError => e
  puts e.message
end
begin
  system("definitely-not-a-command-xyz", exception: true)
rescue SystemCallError => e
  p e.class
end
p system("true")
# after an environment Hash
p system({"SPX_O" => "o"}, "sh", "-c", "echo $SPX_O; exit 2", out: File::NULL)
p $?.exitstatus
p system({"SPX_P" => "p"}, "echo [$SPX_P]; pwd", chdir: "/")
p system({"SPX_Q" => "q"}, "echo [$SPX_Q]", exception: true)
