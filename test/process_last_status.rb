# Process.last_status is $?: the last child's Process::Status, nil before
# any (#7196).
p Process.last_status
system("exit 3")
p $?.to_i
p $?.exitstatus
p $?.success?
p Process.last_status.exitstatus
p Process.last_status.success?
def run
  system("true")
  Process.last_status.success?
end
p run
