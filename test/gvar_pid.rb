# $$ is the process id, Process.pid by another name (webrick logs
# "pid=#{$$}" as its server starts)
p $$.class
p $$ == Process.pid, $$.positive?
puts "start: pid=#{$$}".sub(/\d+/, "N")
def run = yield
run { p $$ == Process.pid }
