# IO.popen("ls") in a comment, beside an eval that runs no popen
def one = eval("1")
p IO.respond_to?(:__sp_popen, true)
